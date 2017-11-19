assert = require('assert')
Bitfinex = require('../lib/Bitfinex')

describe 'fetch ticker', ->
	it 'succeeds', ->
		bitfinex = new Bitfinex()
		bitfinex.ticker('btcusd').then (result) ->
			assert result.volume?

describe 'fetch symbols_details', ->
	it 'succeeds', ->
		bitfinex = new Bitfinex()
		bitfinex.symbols_details().then (result) ->
			assert result[0].pair?

describe 'fetch something private', ->
	it 'errors when there is no key or secret', ->
		bitfinex = new Bitfinex()
		try
			bitfinex.balances()
		catch error
			assert error?
