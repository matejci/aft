
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

import { ContextMenu, MenuItem, ContextMenuTrigger } from 'react-contextmenu/dist/react-contextmenu'

import { usePlayer } from '../../shared/components/stores/playerStore'
import { makeObservable } from '../../shared/components/Observable'

import NumberFormat from 'react-number-format'

import Visibility from '@material-ui/icons/Visibility'
import ChatBubbleRounded from '@material-ui/icons/ChatBubbleRounded'
import ChangeHistoryTwoTone from '@material-ui/icons/ChangeHistoryTwoTone'
import HistoryOutlined from '@material-ui/icons/HistoryOutlined'

import TakkoPlayer from './TakkoPlayer'
import Item from './Item'
// import Carousel from './Carousel'

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

// const PlayerContext = React.createContext({ player: { width: 0 }, setPlayer: () => {} })
const PlayerContext = React.createContext({ width: 0 })


export default class PostWithBottomCard extends React.Component {
// export default class Post extends React.PureComponent {

  constructor(props) {
    super(props)

    const playerStore = null

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
      width: 0,
      comment: "",
      playing: false
    }

    this.toggle = this.toggle.bind(this)
    this.togglePlayer = this.togglePlayer.bind(this)
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

  togglePlayer() {
    this.setState({
      playing: !this.state.playing
    })
  }

  componentDidMount() {
    console.log("class MediaModal componentDidMount")

    console.log('this.props.post')
    console.log(this.props.post)

    // enableInlineVideo(this.videoRef)

    if (!isEmpty(this.TakkoPlayer)) {
      console.log('video player ref exists')

      this.TakkoPlayer.ref.current.addEventListener('play', () => {
       // setVideoPlaying(true)
        console.log('event listener play')
      })
      this.TakkoPlayer.ref.current.addEventListener('pause', () => {
        // setVideoPlaying(false)
        console.log('event listener pause')
      })
    } else {
      console.log('no video player')
    }
    
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
    // this.carouselComponent.carouselNext()
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

      const width = Math.round(bounds.width)
      const height = (16/9)*width
      const borderRadius = width/15
      // this.playerStore = makeObservable({ width: width, count: 0 })
      // this.playerStore = makeObservable({ width: Math.round(bounds.width), count: 0 })

      // usePlayer().actions.init(80)

      // React.memo(usePlayer().actions.setWidth(80))
      // usePlayer().actions.incrementCount()

      // const { player, setPlayer } = React.useContext(PlayerContext)
      // setPlayer({width: Math.round(bounds.width) })

      // const boundWidth = () => { return Math.round(bounds.width) }

      // consider that knowing bounds is only possible *after* the view renders
      // so you'll get zero values on the first run and be informed later

      return (
        <React.Fragment>
          <div ref={ref} className={styles.takkoMedia} style={{ height: height }}>
            <div className={styles.mediaContent} style={{ borderRadius: borderRadius }}>

               {/*<p style={{textAlign: 'center'}}>{ Math.round(bounds.width) }px</p> */}
               {/*<p style={{textAlign: 'center'}}>{ borderRadius }px</p> */}

              <ContextMenuTrigger
                id="videoCoverContext"
                attributes={{
                  className: styles.videoCoverContextMenuWrapper
                }}>

                <TakkoPlayer
                  ref={instance => { this.TakkoPlayer = instance }}
                  source={this.state.source}
                  width={width}
                  height={height}
                  borderRadius={borderRadius}
                  post={this.props.post} />

                {/*<VideoCover
                  id={this.state.source}
                  videoOptions={{
                    src: this.state.source,
                    ref: videoRef => {
                      this.videoRef = videoRef
                    },
                    onClick: () => {
                      if (this.videoRef && this.videoRef.paused) {
                        this.videoRef.play()
                        // this.togglePlayer()
                      } else if (this.videoRef) {
                        this.videoRef.pause()
                        // this.togglePlayer()
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
                /> */}
              </ContextMenuTrigger>

              <ContextMenu id="videoCoverContext" className={styles.contextMenu}>
                <MenuItem key={JSON.stringify(this.state.selectedPost.user.username)} data={{foo: 'bar'}} onClick={this.handleClick} className={styles.menuItem}>
                  @{this.state.selectedPost.user.username}
                </MenuItem>
              </ContextMenu>

            </div>

            {/*
            <div className={styles.gradient} style={{ borderBottomLeftRadius: borderRadius*0.95, borderBottomRightRadius: borderRadius*0.95 }}></div>

            <div className={styles.carousel}>
              { (this.state.items) && (

                <Carousel ref={instance => (this.carouselComponent = instance)} items={this.state.items} post={this.state.element} selectedPost={this.state.selectedPost} posts={this.state.items} onPostEnded={this.onPostEnded} updateSourceState={this.updateSourceState} />

              )}
            </div>
            */}
          </div>

          <div className={styles.bottomCard} style={{ borderBottomLeftRadius: borderRadius, borderBottomRightRadius: borderRadius, paddingTop: borderRadius*2, top: -(borderRadius*2), maxWidth: width }}>
            <div className={styles.bottomCardInner}>

              <Row className={"justify-content-md-center align-items-center"}>

                <Col xs={{ size: 6 }}>

                  <div className={styles.postInfoWrap}>
                    <div className={styles.profileImage} style={{backgroundImage: "url('" + this.state.selectedPost.user.profile_thumb_url + "')"}}></div>

                    <div className={styles.profileInfo + " align-self-center"}>
                      <h5>@{ this.state.selectedPost.user.username }</h5>
                      <h6>{ this.state.selectedPost.user.display_name }</h6>
                    </div>
                  </div>

                </Col>

                <Col xs={{ size: 6 }}>
                  <div className={styles.postMetricsWrap}>
                    <Row className={"justify-content-md-center align-items-center"}>
                      <Col xs={{ size: 6 }}>
                        <div className={styles.postMetric}>
                          <Visibility style={{ fontSize: 14, marginRight: 5, top: -1, position: 'relative' }} />
                          { <NumberFormat value={this.state.selectedPost.total_views} displayType={'text'} thousandSeparator={true} prefix={""} suffix={""} decimalScale={0} /> }
                        </div>
                      </Col>
                      <Col xs={{ size: 6 }}>
                        <div className={styles.postMetric}>
                          <ChatBubbleRounded style={{ fontSize: 14, marginRight: 5, top: -1, position: 'relative' }} />
                          { <NumberFormat value={this.state.selectedPost.comments_count} displayType={'text'} thousandSeparator={true} prefix={""} suffix={""} decimalScale={0} /> }
                        </div>
                      </Col>
                    </Row>

                    <Row className={"justify-content-md-center align-items-center"}>
                      <Col xs={{ size: 6 }}>
                        <div className={styles.postMetric}>
                          <ChangeHistoryTwoTone style={{ fontSize: 14, marginRight: 5, top: -1, position: 'relative' }} />
                          { <NumberFormat value={this.state.selectedPost.upvotes_count} displayType={'text'} thousandSeparator={true} prefix={""} suffix={""} decimalScale={0} /> }
                        </div>
                      </Col>
                      <Col xs={{ size: 6 }}>
                        <div className={styles.postMetric}>
                          <HistoryOutlined style={{ fontSize: 14, marginRight: 5, top: -1, position: 'relative' }} />
                          { this.state.selectedPost.published }
                        </div>
                      </Col>
                    </Row>
                  </div>
                </Col>

              </Row>

                { !isEmpty(this.TakkoPlayer) ? (
                  <React.Fragment>
                    TakkoPlayer: { JSON.stringify(this.TakkoPlayer.ref.paused) }

                    <button onClick={ this.TakkoPlayer.handlePlayPause }>{this.TakkoPlayer.state.playing ? 'Pause' : 'Play'}</button>
                  </React.Fragment>
                ) : (
                  <React.Fragment>
                    <p>no player</p>
                  </React.Fragment>
                )}

              <div className={styles.postTitle}>
                { this.state.selectedPost.title }
              </div>

              <div className={styles.postDescription}>

                { (this.state.selectedPost.description) ? (
                  <React.Fragment>
                    <h2>Description</h2>
                    <p>
                      {this.state.selectedPost.description}
                    </p>
                  </React.Fragment>
                ) : (
                  <React.Fragment>
                    <p>
                      No description
                    </p>
                  </React.Fragment>
                )}

              </div>

            </div>
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
