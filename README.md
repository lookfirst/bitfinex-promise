bitfinex-promise
================

node.js wrapper for [bitfinex cryptocurrency exchange api](https://www.bitfinex.com/pages/api) using promises

```
npm install bitfinex-promise
```

```
Bitfinex = require('bitfinex-promise')
bf = new Bitfinex('key', 'secret')
bf.ticker('btcusd').then (result) ->
  console.log result
```
