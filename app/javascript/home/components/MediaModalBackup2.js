
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'

import VideoCover from 'react-video-cover'
import enableInlineVideo from 'iphone-inline-video'

import CustomScroll from 'react-custom-scroll'

import ContentEditable from 'react-contenteditable'
import stripHtml from "string-strip-html"

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
      mentionStatus: false,
      mentionValue: "",
    }

    this.regex = this.regex.bind(this)
    this.trigger = this.trigger.bind(this)
    this.toggleMentionStatus = this.toggleMentionStatus.bind(this)
    this.updateMentionValue = this.updateMentionValue.bind(this)
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
        comment: "",
        html: "Hello <span style='color:purple;'>@davidchoimusic</span> <span>d</span>",
      }
    }
    return null
  }

  toggle() {
    this.setState({
      modal: !this.state.modal
    })
  }

  toggleMentionStatus(status) {
    this.setState({
      mentionStatus: status,
    })

    console.log("document.queryCommandState('insertHTML'): ")
    console.log(document.queryCommandState('insertHTML'))
    console.log("document.queryCommandState('bold'): ")
    console.log(document.queryCommandState('bold'))

    if (status) {
      // if current command state is not bold, bold it
      if (!document.queryCommandState('bold')) {
        document.execCommand("bold", false, null)
      }
    } else {
      // if current command state is bold, unbold it
      if (document.queryCommandState('bold')) {
        document.execCommand("bold", false, null)
      }
    }
  }

  updateMentionValue = (value) => {
    console.log("updateMentionValue: " + value)
    console.log("mentionStatus: " + this.state.mentionStatus)

    if (this.state.mentionStatus) {
      this.setState({
        mentionValue: this.state.mentionValue+value
      })
    } else {
      this.setState({
        mentionValue: ""
      })
    }
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
      html: value,
      comment: stripHtml(value),
    })

    console.log("~~~~ handleCommentChange: => " + value)
    console.log("~~~~ handleCommentChange: => comment: " + stripHtml(value))
  }

  regex = (key, mentionValue) => {
    // regex
    var regex = /^[a-zA-Z0-9](\w|)*[a-zA-Z0-9]$/

    console.log(" ")
    console.log("mentionValue:")
    console.log(mentionValue)
    console.log(" ")

    if (key == "@" || key == "#") {
      this.toggleMentionStatus(true)

      event.preventDefault()
      document.execCommand("insertHTML", false, "<span style='color:purple;'>"+ key +"</span>")
      // document.execCommand("insertHTML", false, "<span style='color:purple;'>"+ key +"</span>")

      console.log("trigger toggleMentionStatus true")

      console.log(" ")
      console.log("trigger @")
      console.log(" ")
    } else if (key == " ") {
      if (this.state.mentionStatus == true) {
        this.toggleMentionStatus(false)

        event.preventDefault()
        document.execCommand("insertHTML", false, "<span style='color:red;'> ‎</span>")
        // document.execCommand("insertHTML", false, "<span style='color:red;'> d"+ key +"</span>")

        // document.execCommand("removeFormat", false, null)
        // document.execCommand("insertHTML", false, key)

        console.log("trigger toggleMentionStatus false")
      }
      
      console.log("trigger space")
    } else if (!regex.test(mentionValue) && mentionValue.length > 1) {

      console.log("---")
      console.log("regex.test(this.state.mentionValue)")
      console.log(regex.test(mentionValue))
      console.log(this.state.mentionValue)
      console.log("---")

      if (this.state.mentionStatus == true) {
        this.toggleMentionStatus(false)

        event.preventDefault()
        document.execCommand("insertHTML", false, "<span>" + key + "</span>")

        console.log("trigger toggleMentionStatus false")
      }
    }
  }

  trigger = (event) => {
    const target = event.target
    const key = event.key

    console.log(" ")
    console.log("trigger key: ")
    console.log(key)
    console.log(" ")

    // this.updateMentionValue(key).bind(this)
    if (this.state.mentionStatus && key.length == 1) {
    // if (this.state.mentionStatus) {
      this.setState({
        mentionValue: this.state.mentionValue+key
      }, this.regex(key, this.state.mentionValue+key))
    } else if (key.length > 1) {
      // meta keys
      // ignore?
      // this.setState({
      //   mentionValue: ""
      // }, this.regex(key, ""))
    } else {
      // space key
      this.setState({
        mentionValue: ""
      }, this.regex(key, ""))
    }
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



              <ContentEditable
                innerRef={this.contentEditable}
                className={styles.commentBox}
                html={this.state.html} // innerHTML of the editable div
                disabled={false}       // use true to disable editing
                onChange={this.handleCommentChange} // handle innerHTML change
                onKeyDown={this.trigger}
                // onKeyUp={this.trigger}
                // tagName='article' // Use a custom HTML tag (uses a div by default)
              />

            </div>
          </Col>
        </Row>

      </Modal>
    )
  }
}


