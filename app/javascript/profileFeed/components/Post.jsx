
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring/renderprops'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import Post from '../../post/components/Post'

import cx from 'classnames'
import styles from '../css/styles.css'


export default class PostWrapper extends React.Component {

  constructor(props) {
    super(props)

    const element = props.element.item
    const items = element ? element.items : []
    this.selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    this.state = {
      element: props.element,
      selectedPost: this.selectedPost,
      playing: false,
      modal: false
    }

    this.syncSelectedPost = this.syncSelectedPost.bind(this)
    this.toggleModal = this.toggleModal.bind(this)
  }

  componentDidMount() {
    console.log("class PostWrapper componentDidMount")
  }

  componentWillUnmount() {

  }

  toggleModal() {
    console.log("toggleModal")
    // this.setState({ modal: !this.state.modal })

    this.props.toggleModal(this.state.element)
  }

  syncSelectedPost = (selectedPost) => {
    console.log("syncSelectedPost")
  }

  render() {

    const element = this.state.element
    const selectedPost = this.state.selectedPost

    const Loading = (props) => {
      return (
        <div {...props} className={styles.spinnerLoading}>
          <Row className="justify-content-md-center align-items-center h-100">
            <Col md="5">
              <div className={styles.spinner}>
                <div className={styles.doubleBounce1}></div>
                <div className={styles.doubleBounce2}></div>
              </div>
              <p>{props.message}</p>
            </Col>
          </Row>
        </div>
      )
    }

    const PostBox = () => {
      return (
        <div className={styles.posts} style={{ backgroundImage: `url('${selectedPost.media_thumbnail.thumb.url}`}}>
        {/*<div className={styles.posts}>*/}
          {/*<h5>ID: {element.item.id}</h5>*/}
          {/*title: { selectedPost.title }*/}
        </div>
      )
    }

    const Modal = () => {
      return (
        <div className={styles.modal}>
          MODAL
          {/*<Post post={element} syncSelectedPost={this.syncSelectedPost} />*/}
        </div>
      )
    }

    return (
      <Col style={this.props.style} className={styles.sectionCol} xs={{ size: 12 }} onClick={ () => this.toggleModal() }>
        {/*<a href="#" className={styles.profilePostLink}>*/}
          <PostBox />

          { this.state.modal && (
            <Modal />
          )}

          {/*(this.props.playingElement == element.id) ? ( */}
          {/*this.state.playing ? (
            <Post post={element} syncSelectedPost={this.syncSelectedPost} />
          ) : (
            <PostBox />
          )*/}
        {/*</a>*/}
      </Col>
    )
  }

}
