---
title: wepack3 详解
date: 2017-12-12T15:47:11+08:00
categories: [前端技术]
tags: [webpack3]
---
[webpack3中文文档](https://doc.webpack-china.org/)
[Fis3构建迁移Webpack之路](https://segmentfault.com/a/1190000012068849)
[大公司里怎样开发和部署前端代码](https://github.com/fouber/blog/issues/6)
[awesome-webpack-cn](https://github.com/webpack-china/awesome-webpack-cn)
[webpack进阶之插件篇](https://segmentfault.com/a/1190000005742122)
[webpack飞行手册 *推荐*](https://segmentfault.com/a/1190000012356915)

```js
module: {
  rules: [
    {
      test: /\.js$/,
      use: 'babel-loader?cacheDirectory', // 开启 babel-loader 缓存
      include: [path.resolve('src'), path.resolve('test')],
      exclude: /node_modules/
    },
    {
      test: /\.(css|scss)$/,
      use: ['style-loader', 'css-loader', 'postcss-loader', 'sass-loader']
    },
    {
      test: /\.(png|jpe?g|gif|svg)(\?.*)?$/i,
      loader: 'url-loader',
      options: {
        limit: 10 * 1024,
        name: 'images/[name].[ext]?[hash]'
      }
    },
    {
      test: /\.(mp4|webm|ogg|mp3|wav|flac|aac)(\?.*)?$/,
      loader: 'url-loader',
      options: {
        limit: 10 * 1024,
        name: 'media/[name].[ext]?[hash]'
      }
    },
    {
      test: /\.(woff2?|eot|ttf|otf)(\?.*)?$/,
      loader: 'url-loader',
      options: {
        limit: 10 * 1024,
        name: 'fonts/[name].[ext]?[hash]'
      }
    }
  ]
},
```

```js
module: {
     rules: [
         {
             // 后缀正则
             test: /\.js$/,
             // 加载器组
             use: [
                 {
                     loader: 'babel-loader',
                 },
                 {
                     loader: 'eslint-loader',
                 },
             ],
             exclude: /node_modules/,
         },
         {
             test: /\.less$/,
             use: ExtractTextPlugin.extract({
                 fallback: 'style-loader',
                 use: [
                     'css-loader',
                     'postcss-loader',
                     'less-loader',
                 ],
             }),
             exclude: /node_modules/,
         },

         {
             test: /\.(woff|woff2)(\?v=\d+\.\d+\.\d+)?$/,
             use: [
                 {
                     loader: 'url-loader',
                     options: {
                         name: '[path][name].[ext]',
                         limit: 10240,
                         mimetype: 'application/font-woff',
                     }
                 },
             ],
             // loaders: ['url-loader?&limit=102400&mimetype=application/font-woff'],
         },
         {
             test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
             use: [
                 {
                     loader: 'url-loader',
                     options: {
                         name: '[path][name].[ext]',
                         limit: 10240,
                         mimetype: 'application/octet-stream',
                     }
                 },
             ],
             // loaders: ['url-loader?name=[path][name].[ext]&limit=1024&mimetype=application/octet-stream'],
         },
         {
             test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
             use: [
                 {
                     loader: 'file-loader',
                     options: {
                         name: '[path][name].[ext]',
                     }
                 },
             ],
             // loaders: ['file-loader?name=[path][name].[ext]'],
         },
         {
             test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
             use: [
                 {
                     loader: 'url-loader',
                 },
             ],
             // loaders: ['url-loader?name=[path][name].[ext]&limit=1024&mimetype=image/svg+xml'],
         },
         {
             test: /\.(png|jpg|gif)$/,
             use: [
                 {
                     loader: 'url-loader',
                 },
             ],
             // loaders: ['url-loader?name=[path][name].[ext]?[hash]&limit=204800000'], // 单位bit
             exclude: /node_modules/,
         },
     ],
 },
```
