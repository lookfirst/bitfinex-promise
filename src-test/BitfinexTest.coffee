assert = require('assert')
Bitfinex = require('../lib/Bitfinex')

describe 'fetch ticker', ->
	it 'succeeds', ->
		bitfinex = new Bitfinex()
		bitfinex.ticker('btcusd').then (result) ->
			assert result.volume?

describe 'fetch something private', ->
	it 'errors when there is no key or secret', ->
		bitfinex = new Bitfinex()
		try
			bitfinex.balances()
		catch error
			assert error?
