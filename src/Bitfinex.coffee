Promise = require('bluebird')
request = require('request')
crypto = require('crypto')
qs = require('qs')

#
# Implementation of the Bitfinex API using promises
# @see https://www.bitfinex.com/pages/api
#
module.exports = class Bitfinex
	constructor: (@key, @secret) ->
		@version = '/v1/'
		@url = 'https://api.bitfinex.com' + @version
		@nonce = Math.round((new Date()).getTime() / 1000)

	# Public API functions

	ticker: (symbol) ->
		@_makePublicRequest("pubticker/#{symbol}")

	today: (symbol) ->
		@_makePublicRequest("today/#{symbol}")

	symbols: ->
		@_makePublicRequest('symbols')

	lends: (currency, timestamp, limit_lends = 50) ->
		@_makePublicRequest("lends/#{currency}", {timestamp: timestamp, limit_lends: limit_lends})

	lendbook: (symbol, limit_bids = 50, limit_asks = 50) ->
		@_makePublicRequest("lendbook/#{symbol}", {limit_bids: limit_bids, limit_asks: limit_asks})

	orderbook: (symbol, limit_bids = 50, limit_asks = 50) ->
		@_makePublicRequest("book/#{symbol}", {limit_bids: limit_bids, limit_asks: limit_asks})

	# Private API functions

	newOrder: (symbol, amount, price, exchange, side, type, is_hidden = false) ->
		params =
			symbol: symbol
			amount: amount
			price: price
			exchange: exchange
			side: side
			type: type
			is_hidden: is_hidden
		@_makePrivateRequest('order/new', params)

	# @param [Array] multi An array of {Bitfinex#newOrder} params
	newOrderMultiple: (multi) ->
		@_makePrivateRequest('order/new/multi', multi)

	cancelOrder: (order_id) ->
		@_makePrivateRequest('order/cancel', order_id: order_id)

	cancelOrdersMulti: (order_ids) ->
		@_makePrivateRequest('order/cancel/multi', order_id: order_ids)

	cancelOrdersAll: ->
		@_makePrivateRequest('order/cancel/all')

	replaceOrder: (order_id, symbol, amount, price, exchange, side, type, is_hidden) ->
		params =
			order_id: order_id
			symbol: symbol
			amount: amount
			exchange: exchange
			side: side
			type: type
			is_hidden: is_hidden

		if price?
			params.price = price

		@_makePrivateRequest('order/cancel/replace', params)

	orderStatus: (order_id) ->
		@_makePrivateRequest('order/status', order_id: order_id)

	activeOrders: ->
		@_makePrivateRequest('orders')

	activePositions: ->
		@_makePrivateRequest('positions')

	claimPosition: (position_id) ->
		@_makePrivateRequest('position/claim', position_id: position_id)

	pastTrades: (symbol, timestamp, limit_trades) ->
		@_makePrivateRequest('mytrades', {symbol: symbol, timestamp: timestamp, limit_trades: limit_trades})

	newOffer: (currency, amount, rate, period, direction) ->
		@_makePrivateRequest('offer/new', {currency: currency, amount: amount, rate: rate, period: period, direction: direction})

	cancelOffer: (offer_id) ->
		@_makePrivateRequest('offer/cancel', offer_id: offer_id)

	offerStatus: (offer_id) ->
		@_makePrivateRequest('offer/status', offer_id: offer_id)

	activeOffers: ->
		@_makePrivateRequest('offers')

	activeCredits: ->
		@_makePrivateRequest('credits')

	balances: ->
		@_makePrivateRequest('balances')

	accountInfos: ->
		@_makePrivateRequest('account_infos')

	marginInfos: ->
		@_makePrivateRequest('margin_infos')

	# @private
	_nonce: -> '' + @nonce++

	# @private
	_makePublicRequest: (path, params) ->
		@_makeRequest(path, params, 'GET')

	# @private
	_makePrivateRequest: (path, params) ->
		if !@key || !@secret
			throw Error('missing api key or secret')
		@_makeRequest(path, params, 'POST')

	# @private
	_makeRequestObject: (path, params, method) ->
		requestObj =
			method: method
			timeout: 15000
			url: @url + path

		if method == 'GET'
			if params?
				requestObj.url = "#{requestObj.url}?#{qs.stringify(params)}"
		else if method == 'POST'
			payload = params || {}
			payload.request = @version + path
			payload.nonce = @_nonce()

			payload = new Buffer(JSON.stringify(payload)).toString('base64')
			signature = crypto.createHmac('sha384', @secret).update(payload).digest('hex')

			headers =
				'X-BFX-APIKEY': @key
				'X-BFX-PAYLOAD': payload
				'X-BFX-SIGNATURE': signature

			requestObj.headers = headers

		requestObj

	# @private
	_makeRequest: (path, params, method) ->
		requestObj = @_makeRequestObject(path, params, method)

		new Promise (resolve, reject) ->
			request requestObj, (err, response, body) ->
				if err || response.statusCode != 200
					reject(statusCode: response.statusCode, body: body, err: err)

				try
					result = JSON.parse(body)
				catch error
					return reject(body: body)

				if result.message?
					return reject(message: result)

				resolve(result)
