
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../css/styles.css'

import MenuItem from './MenuItem'


const Menu = (items, selected, selectedPost, scrollToItem, updateSourceState) =>
  items.map(post => { 
    return <MenuItem post={post} key={post._id} selected={selected} selectedPost={selectedPost} scrollToItem={scrollToItem} updateSourceState={updateSourceState} />
  })

export { Menu }
