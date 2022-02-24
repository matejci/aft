
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import VideoCover from 'react-video-cover'
import enableInlineVideo from 'iphone-inline-video'

import { MentionsInput, Mention } from 'react-mentions'

import { useWindowSize } from '../../util/Hooks'

import { usePlayer } from '../../shared/components/stores/playerStore'
import { makeObservable } from '../../shared/components/Observable'

import NumberFormat from 'react-number-format'

import Visibility from '@material-ui/icons/Visibility'
import ChatBubbleRounded from '@material-ui/icons/ChatBubbleRounded'
import ChangeHistoryTwoTone from '@material-ui/icons/ChangeHistoryTwoTone'
import HistoryOutlined from '@material-ui/icons/HistoryOutlined'

import TakkoPlayerV2 from './TakkoPlayerV2'
import Carousel from './Carousel'
import PlayedProgressBar from './ProgressBar'
import { PlayerControls, updateSelectedPost, updatePlaying, updatePlayerControlsCarouselMode } from './PlayerControls'
import { Gradient, updateGradientCarouselMode } from './Gradient'

import { parse } from 'node-html-parser'

import cx from 'classnames'
import styles from '../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

// const PlayerContext = React.createContext({ player: { width: 0 }, setPlayer: () => {} })
const PlayerContext = React.createContext({ width: 0 })


export default class Post extends React.Component {
// export default class Post extends React.PureComponent {

  constructor(props) {
    super(props)

    const playerStore = null

    this.element = this.props.post

    this.items = this.element ? this.element.items : []
    this.selectedPost = this.items ? this.items.find((item)=> item.id == this.element.selected_id ) : {}
    this.source = this.selectedPost ? this.selectedPost.media_file_url : ""

    this.state = {
      errors: {},
      prevPropsPost: {},
      post: this.props.post,
      selectedPost: this.selectedPost,
      items: this.items,
      modal: false,
      width: 0,
      comment: "",
      playing: false,
    }

    this.gradient = React.createRef()

    this.toggle = this.toggle.bind(this)
    this.togglePlayer = this.togglePlayer.bind(this)
    this.toggleCarouselMode = this.toggleCarouselMode.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
    this.pause = this.pause.bind(this)
    this.play = this.play.bind(this)
    this.onPostEnded = this.onPostEnded.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleProgress = this.handleProgress.bind(this)
    this.updateSourceState = this.updateSourceState.bind(this)
    this.updatePlayingItems = this.updatePlayingItems.bind(this)
  }


  static getDerivedStateFromProps(props, state) {
    if (props.post !== state.prevPropsPost) {
      const element = props.post
      const items = element ? element.items : []
      const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}
      const selectedPostProp = props.selectedPost ? props.selectedPost : selectedPost

      return {
        post: props.post,
        selectedPost: items ? items.find((item)=> item.id == element.selected_id ) : {},
        items: items
      }
    }
    return null
  }

  toggle() {
    this.setState({
      modal: !this.state.modal
    })
  }

  togglePlayer() {
    this.setState({
      playing: !this.state.playing
    })
  }

  componentDidMount() {
    // console.log("class Post componentDidMount")
  }

  componentWillUnmount() {

  }

  /*
  shouldComponentUpdate(nextProps, nextState) {
    if (nextState.playing !== this.state.playing) {
      // do not re-render on video state change to prevent reload
      return false
    } else {
      return true
    }
  }
  */

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
    console.log("~~~~ handleInputChange: => " + value)
  }

  handleProgress = state => {
    // console.log('onProgress', state)
    if (this.ProgressBar) {
      this.ProgressBar.updateProgress(state.played)
    }

    if (this.Carousel) {
      this.Carousel.updateProgress(state.played)
    }
  }

  onSelect = key => {
    this.setState({ selected: key })
  }

  updatePlayingItems = playing => {
    if (this.Carousel) {
      this.Carousel.updatePlayingItems(playing)
    }
  }

  updateSourceState = (selectedPost) => {
    if (this.TakkoPlayer) {
      this.TakkoPlayer.updateSourceState(selectedPost)
      this.TakkoPlayer.setPlaying(true)
    }

    if (this.ProgressBar) {
      this.ProgressBar.updateProgress(0)
    }

    updateSelectedPost(selectedPost)

    if (this.Carousel) {
      this.Carousel.syncSelectedPost(selectedPost)
    }
  }

  onPostEnded = () => {
    // console.log(" ")
    // console.log("onPostEnded")
    if (this.Carousel) {
      this.Carousel.carouselNext()
    }
  }

  handleClick(e, data) {
    console.log(data.foo)
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

  animateCSS = (ref, animationName, callback) => {
    const node = ref.current

    if (isEmpty(node)) { return }

    node.classList.add('animated', animationName)

    function handleAnimationEnd() {
        node.classList.remove('animated', animationName)
        node.removeEventListener('animationend', handleAnimationEnd)

        if (typeof callback === 'function') callback()
    }

    node.addEventListener('animationend', handleAnimationEnd)
  }

  toggleCarouselMode = () => {
    updateGradientCarouselMode()
    updatePlayerControlsCarouselMode()

    if (this.Carousel) {
      this.Carousel.updateCarouselMode()
    }
  }

  pause = (e) => {
    !isEmpty(e) && e.preventDefault()
    // console.log("pause()")
    if (this.TakkoPlayer) {
     this.TakkoPlayer.pause()
    }
  }

  play = (e) => {
    !isEmpty(e) && e.preventDefault()
    // console.log("play()")
    if (this.TakkoPlayer) {
      this.TakkoPlayer.play()
    }
  }

  ref = player => {
    this.TakkoPlayer = player
  }

  render() {

    function isEmpty(obj) {
      for(var key in obj) {
          if(obj.hasOwnProperty(key))
              return false
      }
      return true
    }

    const PlayerToggleButton = () => {


      return (
        <React.Fragment>
          { JSON.stringify(this.state.playing) }
        </React.Fragment>
      )
    }

    const TakkoMedia = () => {
      const [ref, bounds] = useMeasure()
      const windowSize = useWindowSize()

      const processHeight = Math.round(bounds.height)

      var verticalDifference = windowSize.height-processHeight

      var width = Math.round(bounds.width)
      var height = (16/9)*width
      var borderRadius = width/15

      var processVertical = (windowSize.width < 767) ? (verticalDifference*0.85) : (verticalDifference/2)
      var verticalTop = processVertical ? processVertical : 0


      return (
        <React.Fragment>
          <div ref={ref} className={styles.takkoMedia}>
            <div className={styles.mediaContent} style={{ borderRadius: borderRadius, marginTop: verticalTop }}>

              <TakkoPlayerV2
                ref={instance => { this.TakkoPlayer = instance }}
                source={this.state.source}
                width={width}
                height={height}
                borderRadius={borderRadius}
                post={this.props.post}
                syncSelectedPost={this.props.syncSelectedPost}
                updateSourceState={this.updateSourceState}
                handleProgress={this.handleProgress}
                updatePlayingItems={this.updatePlayingItems}
                toggleCarouselMode={this.toggleCarouselMode}
                onPostEnded={this.onPostEnded}
              />

              { (this.state.items) && (
                <Carousel
                  ref={instance => { this.Carousel = instance }}
                  items={this.state.items}
                  element={this.state.post}
                  play={this.play}
                  pause={this.pause}
                  updateSourceState={this.updateSourceState}
                />
              )}

              <Gradient
                innerRef={this.gradient}
                toggleCarouselMode={this.toggleCarouselMode}
                borderRadius={borderRadius}
              />

            </div>

            <PlayedProgressBar ref={instance => { this.ProgressBar = instance }} />
            <PlayerControls selectedPost={this.state.selectedPost} playing={this.state.playing} play={this.play} pause={this.pause} />

          </div>
        </React.Fragment>
      )
    }

    return (
      <React.Fragment>

        { (this.state.post && this.state.selectedPost) ? (
          <React.Fragment>

            <TakkoMedia />

          </React.Fragment>
        ) : (
          <React.Fragment>

            <Row className={styles.postRow + " row align-items-center justify-content-md-center"}>

              <Col md={{ size: 12 }}>

                <div className={styles.loading}>
                  Loading...
                </div>

              </Col>

            </Row>

          </React.Fragment>
        )}

      </React.Fragment>
    )
  }
}
