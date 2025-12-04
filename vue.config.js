const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  publicPath: "./",
  devServer: {
    proxy: {
      '^/api': {
        target: 'http://localhost:3000',
        pathRewrite: {
          '^/api': ''
        },
      },
    }
  },
})
