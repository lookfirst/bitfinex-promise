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

Pull requests and donations welcome: 1KUeUSKN31bPZHvFQ4G9MYRo3VBSsRKR3m
