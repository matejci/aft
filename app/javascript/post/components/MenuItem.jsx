
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import cx from 'classnames'
import styles from '../css/styles.css'


export default class MenuItem extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
  }

  componentDidMount() {
    console.log("class MenuItem componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (e, scrollToItem, updateSourceState) => {
    console.log("handleClick")

    console.log(this.props.post)

    updateSourceState(this.props.post)
    scrollToItem(this.props.post)
  }

  render() {
    const post = this.props.post

    const verticalPadding = 12
    const height = this.props.height-(verticalPadding*2)
    const width = (9/16)*height
    const horizontalPadding = this.props.height/18
    const bottomPadding = this.props.height/25
    const borderRadius = width/6

    return (
      <a
        style={{ marginRight: horizontalPadding, marginBottom: bottomPadding }}
        onClick={ (e) => this.handleClick(e, this.props.scrollToItem, this.props.updateSourceState) }
        className={this.props.selected ? cx(styles.menuItemLink, styles.active) : styles.menuItemLink}
      >
        <div className={styles.menuItemContent} style={{width: width, height: height, backgroundImage: "url('" + post.media_thumbnail.url + "')", borderRadius: borderRadius}}>
          {/* post.media_thumbnail.url */}
        </div>
      </a>
    )
  }

}
