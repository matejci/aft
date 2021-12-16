
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'

import VideoCover from 'react-video-cover'
import enableInlineVideo from 'iphone-inline-video'

import CustomScroll from 'react-custom-scroll'
// import ScrollMenu from 'react-horizontal-scrolling-menu'

import { MentionsInput, Mention } from 'react-mentions'

import Item from './Item'
import Carousel from './Carousel'

import cx from 'classnames'
import styles from '../css/styles.css'


const users = [
  {
    id: 'davidchoi',
    display: '@davidchoi',
  },
  {
    id: 'walter',
    display: '@walterwhite',
  },
  {
    id: 'jesse',
    display: '@jessepinkman',
  },
  {
    id: 'gus',
    display: '@GustavoFring',
  },
  {
    id: 'saul',
    display: '@SaulGoodman',
  },
  {
    id: 'hank',
    display: '@hankschrader',
  },
  {
    id: 'skyler',
    display: '@skylerwhite',
  },
  {
    id: 'mike',
    display: '@mike_ehrmantraut',
  },
  {
    id: 'lydia',
    display: '@lydìã_rôdarté_qüayle'
  }
]

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class MediaModal extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      prevPropsPost: {},
      modal: false,
      acceptedPolicy: false,
      post: this.props.post,
      source: this.props.post.media_file.url,
      items: this.props.items,
      selectedPost: this.props.post,
      comment: "",
    }

    this.renderUserSuggestion = this.renderUserSuggestion.bind(this)
    this.toggle = this.toggle.bind(this)
    this.onPostEnded = this.onPostEnded.bind(this)
    this.handleCommentChange = this.handleCommentChange.bind(this)
    this.updateSourceState = this.updateSourceState.bind(this)
  }

  static getDerivedStateFromProps(props, state) {
    if (props.post !== state.prevPropsPost) {
      return {
        prevPropsPost: props.post,
        post: props.post,
        source: props.post.media_file.url,
        items: props.items,
        selectedPost: props.post,
      }
    }
    return null
  }

  toggle() {
    this.setState({
      modal: !this.state.modal
    })
  }

  componentDidMount() {
    console.log("class MediaModal componentDidMount")

    console.log('this.props.post')
    console.log(this.props.post)

    // enableInlineVideo(this.videoRef)
  }

  componentWillUnmount() {

  }

  handleCommentChange(event) {
    const target = event.target
    const value = target.value

    this.setState({
      comment: value
    })
    console.log("~~~~ handleCommentChange: => " + value)
  }

  renderUserSuggestion = () => {
    console.log("renderUserSuggestion")
  }

  onSelect = key => {
    this.setState({ selected: key })
  }

  updateSourceState = (post) => {
    this.setState({ selectedPost: post, source: post.media_file.url })
    console.log("updateSourceState(data) completed")
  }

  onPostEnded = () => {
    console.log(" ")
    console.log("onPostEnded")
    this.carouselComponent.carouselNext()
  }


  render() {

    const post = this.props.post

    // let menu = this.menuItems

    // this.menuItems = Menu(this.props.items, post)



    return (
      <Modal
        isOpen={this.props.modal}
        toggle={this.props.toggle}
        fade={false}
        className={styles.modal}
        contentClassName={styles.modalContent}
        centered>

        <Row className="no-gutters h-100">
          <Col md={7} className="h-100">
            <div className={styles.mediaContent}>

              <VideoCover
                videoOptions={{
                  src: this.state.source,
                  ref: videoRef => {
                    this.videoRef = videoRef
                  },
                  onClick: () => {
                    if (this.videoRef && this.videoRef.paused) {
                      this.videoRef.play()
                    } else if (this.videoRef) {
                      this.videoRef.pause()
                    }
                  },
                  onEnded: () => {
                    // this.props.()
                    // console.log("onEnded")
                    this.onPostEnded()
                  },
                  autoPlay: true,
                  loop: false,
                  muted: false,
                  title: 'click to play/pause',
                  playsInline: true,
                }}
                className={styles.player}
                id="takkoPlayer"
              />

              <div className={styles.carousel}>

                <Carousel ref={instance => (this.carouselComponent = instance)} items={this.props.items} post={this.props.post} selectedPost={this.state.selectedPost} posts={this.props.posts} onPostEnded={this.onPostEnded} updateSourceState={this.updateSourceState} />

              </div>

            </div>
          </Col>

          <Col md={5}>
            <div className={styles.postContent}>

              <div className={styles.postHeader}>

                <Row className="no-gutters">
                  <Col xs={{ size: 3, order: 1 }}>

                    <div className={styles.postUserProfileImage}>
                      <img src={post.user.profile_thumb_url} className="img-fluid rounded-circle" />
                    </div>

                  </Col>

                  <Col xs={{ size: 9, order: 1 }}>
                    <div className={styles.postUserDetails}>
                      <div className={styles.postName}>
                        { post.user.first_name } { post.user.last_name }
                      </div>

                      <div className={styles.postUsername}>
                        @{ post.user.username }
                      </div>
                    </div>
                  </Col>

                </Row>

              </div>

              <div className={styles.postTitle}>
                { post.title }
              </div>

              comments here..


              <MentionsInput
                className={styles.commentBox}
                value={this.state.comment}
                onChange={this.handleCommentChange}
                inputRef={ref => {
                  this.commentBox = ref
                }}
              >
                <Mention
                  trigger="@"
                  data={users}
                  appendSpaceOnAdd={true}
                  displayTransform={ username => `@${username}` }
                  // allowSuggestionsAboveCursor={true}
                  // renderSuggestion={this.renderUserSuggestion}
                />
                {/*<Mention
                  trigger="#"
                  data={this.requestTag}
                  renderSuggestion={this.renderTagSuggestion}
                />*/}
              </MentionsInput>


            </div>
          </Col>
        </Row>

      </Modal>
    )
  }
}
