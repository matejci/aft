// process.env.NODE_ENV = process.env.NODE_ENV || 'production'

// const environment = require('./environment')

// module.exports = environment.toWebpackConfig()

process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
// NOTE: sass? maybe different loader
environment.loaders.append('css', {
	test: /\.css$/,
	use: [
		{
	      loader: 'style-loader'
	    },
	    {
	      loader: 'css-loader',
	      options: {
	      	modules: {
	         localIdentName: '[hash:base64:5]',
			},
	      },
	    }
	]
})


// // config/webpack/custom.js
// const customConfig = require('./custom')

// // Merge custom config
// environment.config.merge(customConfig)


module.exports = environment.toWebpackConfig()
