
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import VideoCover from 'react-video-cover'
import enableInlineVideo from 'iphone-inline-video'

import { MentionsInput, Mention } from 'react-mentions'

import { ContextMenu, MenuItem, ContextMenuTrigger } from 'react-contextmenu/dist/react-contextmenu'

import Item from './Item'
import Carousel from './Carousel'

import { parse } from 'node-html-parser'

import styles from '../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class Post extends React.Component {

  constructor(props) {
    super(props)

    const element = this.props.post

    const items = element ? element.items : []
    const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    this.state = {
      errors: {},
      prevPropsPost: {},
      modal: false,
      acceptedPolicy: false,
      post: this.props.post,
      source:  selectedPost ? selectedPost.media_file_url : "",
      items: items,
      selectedPost: selectedPost,
      comment: "",
    }

    this.toggle = this.toggle.bind(this)
    this.onPostEnded = this.onPostEnded.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.updateSourceState = this.updateSourceState.bind(this)
  }

  static getDerivedStateFromProps(props, state) {
    if (props.post !== state.prevPropsPost) {
      const element = props.post
      const items = element ? element.items : []
      const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}
      const selectedPostProp = props.selectedPost ? props.selectedPost : selectedPost

      return {
        prevPropsPost: props.post,
        post: props.post,
        source: selectedPostProp ? selectedPostProp.media_file_url : "",
        items: items,
        selectedPost: selectedPostProp,
        comment: "",
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

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
    console.log("~~~~ handleInputChange: => " + value)
  }


  onSelect = key => {
    this.setState({ selected: key })
  }

  updateSourceState = (post) => {
    this.setState({ selectedPost: post, source: post.media_file_url })
    console.log("updateSourceState(data) completed")
  }

  onPostEnded = () => {
    console.log(" ")
    console.log("onPostEnded")
    this.carouselComponent.carouselNext()
  }

  handleClick(e, data) {
    console.log(data.foo);
  }

  submitForm(post, updatePostsState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // console.log("------- post._id.$oid -------: " + JSON.stringify(post))
    var postData = {
      params: {
        post_type: post._id.$oid
      }
    }


    // axios.post(`/post_types.json`, postData, postHeaders)
    axios.delete(`/posts/${post._id.$oid}.json`, postHeaders)
      .then(response => {
        // console.log("response: " + response)px
        // window.location = '/'
        // console.log("JSON.parse success => " + JSON.stringify(response.data))

        // update Posts Type State on index.js
        updatePostsState(response.data.posts)
        // console.log("response.data: " + response.data.post_types)
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
      })
  }

  submitConfirm = (adminSource, updatePostsState) => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => this.submitForm(adminSource, updatePostsState)
        },
        {
          label: 'No',
          // onClick: () => alert('Click No')
        }
      ]
    })
  }

  render() {


    // console.log("post animated.div: " + JSON.stringify(this.props.style))

    return (
      <React.Fragment>

        { (this.state.post && this.state.selectedPost) ? (
          <React.Fragment>

          <div className={styles.postTitle}>
            <h1>{this.state.selectedPost.title}</h1>
          </div>

          <div className={styles.takkoMedia}>
            <div className={styles.mediaContent}>

              <ContextMenuTrigger
                id="videoCoverContext"
                attributes={{
                  className: styles.videoCoverContextMenuWrapper
                }}>

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
              </ContextMenuTrigger>

              <ContextMenu id="videoCoverContext" className={styles.contextMenu}>
                <MenuItem key={JSON.stringify(this.state.selectedPost.user.username)} data={{foo: 'bar'}} onClick={this.handleClick} className={styles.menuItem}>
                  @{this.state.selectedPost.user.username}
                </MenuItem>
              </ContextMenu>

            </div>
          </div>

          <div className={styles.carousel}>

            { (this.state.items) && (

              <Carousel ref={instance => (this.carouselComponent = instance)} items={this.state.items} post={this.state.element} selectedPost={this.state.selectedPost} posts={this.state.items} onPostEnded={this.onPostEnded} updateSourceState={this.updateSourceState} />

            )}

          </div>

          <div className={styles.postDescription}>
            <h2>Description</h2>
            { (this.state.selectedPost.description) ? (
              <p>
                {this.state.selectedPost.description}
              </p>
            ) : (
              <p>
                No description
              </p>
            )}

          </div>

          </React.Fragment>
        ) : (
          <React.Fragment>

            <div className={styles.loading}>
              Loading...
            </div>

          </React.Fragment>
        )}




      </React.Fragment>
    )
  }

  // render() {
  //   const post = this.props.post

  //   // console.log("post animated.div: " + JSON.stringify(this.props.style))

  //   return (
  //     <tr>
  //       <th scope="row">2</th>
  //       <td>Jacob</td>
  //       <td>Thornton</td>
  //       <td>@fat</td>
  //     </tr>
  //     <div style={this.props.style} className={styles.item}>
  //       <div className={styles.post}>
  //         {post._id.$oid} |
  //         {post.email}
  //         <span style={{fontSize:'12px'}}>
  //           {/*<a href="#" onClick={this.handleEditClick(post, this.props.updatePostsState).bind(this)} style={{color:'green'}}>Edit {post.name}</a>*/}
  //         </span>
  //       </div>

  //       {/*<PostsEditModal className="postEditModal" ref={instance => { this.postEditModal = instance }} post={ post } updatePostsState={ this.props.updatePostsState } />*/}
  //     </div>
  //   )
  // }
}
