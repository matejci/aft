
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

const NullFilter = (value) => {
  // filter out null json values to empty strings
  return (value == null) ? "" : value
}

export { NullFilter }