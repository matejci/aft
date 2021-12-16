const requireImages = require.context('images', true, /.(png|jpe?g|gif|svg)$/)
const imagePath = (fileName) => requireImages(`./${fileName}`).default
export default imagePath
