
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

    // videoRef.src = "https://dl.dropboxusercontent.com/s/7b21gtvsvicavoh/statue-of-admiral-yi-no-audio.mp4?dl=1"

    // this.videoRef.src = "https://dl.dropboxusercontent.com/s/7b21gtvsvicavoh/statue-of-admiral-yi-no-audio.mp4?dl=1"
  }

  render() {
    const post = this.props.post

    console.log("post: ")
    console.log(post)

    // console.log(" ")
    // console.log("this.props.selected:")
    // console.log(this.props.selected)
    // console.log(" ")

    // console.log(" ")
    // console.log("post:")
    // console.log(post)


    return (
      <a
        href="#"
        onClick={ (e) => this.handleClick(e, this.props.scrollToItem, this.props.updateSourceState) }
        className={this.props.selected ? cx(styles.menuItemLink, styles.active) : styles.menuItemLink}
      >
        <div className={styles.menuItemContent} style={{backgroundImage: "url('" + post.media_thumbnail.url + "')"}}>
          {post.media_thumbnail.url}
        </div>
      </a>
    )

    // return (
    //   <a
    //     href="#"
    //     onClick={ (e) => this.handleClick(e, this.props.scrollToItem, this.props.updateSourceState) }
    //     className={this.props.selectedPost._id.$oid == post._id.$oid ? cx(styles.menuItemLink, styles.active) : styles.menuItemLink}
    //   >
    //     <div className={styles.menuItemContent} style={{backgroundImage: "url('" + post.media_thumbnail_url + "')"}}>

    //     </div>
    //   </a>
    // )
  }

}

