# client

The DMAC frontend in Vuejs (https://vuejs.org)

## Build Setup
Install Nodejs.

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

```

## Deployment
1. In `build/webpack.prod.conf.js` search for `xHTTPx` to make sure it points to your API server
2. `npm run build` will build the whole app into a `dist` folder.
3. Copy the content or make a symbolic link of `dist` anywhere you want to be served by a http server.

