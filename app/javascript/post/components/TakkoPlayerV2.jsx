
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { useTransition, animated } from 'react-spring/renderprops'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import useMeasure from 'react-use-measure'

import ReactPlayer from 'react-player'
import VideoCover from 'react-video-cover'

import PlayCircleFilledRounded from '@material-ui/icons/PlayCircleFilledRounded'
import PauseCircleFilledRounded from '@material-ui/icons/PauseCircleFilledRounded'

import ScrollMenu from 'react-horizontal-scrolling-menu'
import Carousel from './Carousel'
import PlayedProgressBar from './ProgressBar'
import { PlayerControls, updateSelectedPost, updatePlaying } from './PlayerControls'
import { updateEventSelectedPost, trackEvent } from './EventService'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'
import '!style-loader!css-loader!animate.css'

import EnvClient from '../../util/env'
import mixpanel from 'mixpanel-browser'

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}


export default class TakkoPlayer extends React.Component {

  constructor(props) {
    super(props)

    const element = this.props.post
    const items = element ? element.items : []
    const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    this.state = {
      page: 1,
      total_pages: 2,
      items: items,
      selectedPost: selectedPost,
      previousPlaying: null,
      playing: true,
      played: 0,
      volume: 0.8,
      muted: true,
      loaded: 0,
      playbackRate: 1.0,
      source: "",
      duration: 0,
      carouselMode: true,
      overlay: true,
      postHover: false,
      lastItemVisible: false
    }

    this.carousel = React.createRef()
    this.gradient = React.createRef()
    this.overlay = React.createRef()

    this.showOverlay = this.showOverlay.bind(this)
    this.hideOverlay = this.hideOverlay.bind(this)
    this.dismissOverlay = this.dismissOverlay.bind(this)

    this.toggleCarouselMode = this.toggleCarouselMode.bind(this)
    this.toggleMute = this.toggleMute.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.handlePlayPause = this.handlePlayPause.bind(this)
    this.setPlaying = this.setPlaying.bind(this)
    this.pause = this.pause.bind(this)
    this.play = this.play.bind(this)
    this.handleDuration = this.handleDuration.bind(this)

    this.onPostEnded = this.onPostEnded.bind(this)
    this.validateSource = this.validateSource.bind(this)
    this.getSource = this.getSource.bind(this)
    this.updateSourceState = this.updateSourceState.bind(this)
    this.updateItemsState = this.updateItemsState.bind(this)
    this.updatelastItemVisible = this.updatelastItemVisible.bind(this)

    this.handleProgress = this.handleProgress.bind(this)
    this.handleDuration = this.handleDuration.bind(this)
  }

  /*
  static getDerivedStateFromProps(props, state) {
    if (props.playing !== state.previousPlaying) {
      return {
        previousPlaying: props.playing,
        // playing: props.playing,
        source: props.source
      }
    }
    return null
  }*/

  componentWillMount() {
    this.timeoutID = this.dismissOverlay // cache the timeoutID
  }

  componentDidMount() {
    console.log("class TakkoPlayer componentDidMount")

    updateEventSelectedPost(this.state.selectedPost)
    this.updateSourceState(this.state.selectedPost, true)


    if (EnvClient.mixpanelTracking()) {
      const selectedPost = this.state.selectedPost

      mixpanel.init(EnvClient.mixpanelToken)
      mixpanel.track('Post/Takko', {
        'post_id': `${selectedPost.id}`,
        'title': `${selectedPost.title}`,
        'description': `${selectedPost.description}`,
        'link': `${selectedPost.link}`,
        'user_id': `${selectedPost.user ? selectedPost.user.id : ''}`,
        'username': `${selectedPost.user ? selectedPost.user.username : ''}`,
      })
    }
  }

  componentWillUnmount() {
    clearTimeout(this.timeoutID) // clear the timeoutID
  }

  showOverlay = () => {
    console.log("showOverlay")
    this.setState({ overlay: true })
  }

  hideOverlay = () => {
    console.log("hideOverlay")
    if (this.state.playing == true) {
      // ignore when paused
      // if (this.state.postHover !== true || this.state.overlay == true) {
        this.setState({ overlay: false })
      // }
    }

    // if (this.state.carouselMode !== true) {
    //   if (this.state.playing == true || this.state.overlay == false) {
    //     this.setState({ overlay: false })
    //   }
    // }
  }

  dismissOverlay = () => {
    clearTimeout(this.timeoutID)

    this.timeoutID = setTimeout(
      () => {
        // console.log("dismissOverlay")
        // dismiss overlay only on pause overlay state when video is playing
        if (this.state.playing == true) {
          console.log("dismissOverlay dismissing: " + JSON.stringify(this.state.playing))
          this.animateCSS(this.overlay, "fadeOut", () => {
            console.log("dismissOverlay fadeOut complete")
            this.setState({ overlay: false })
          })
        }
      },
      1500
    )
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

  toggleMute = (e) => {
    // !isEmpty(e) && e.preventDefault()

    this.setState({ muted: !this.state.muted })
  }

  toggleCarouselMode = () => {
    console.log("toggleCarouselMode")

    this.showOverlay()

    if (this.state.carouselMode) {
      this.animateCSS(this.carousel, "fadeOutLeft", () => {
        console.log("fadeOutLeft complete")
        this.setState({ carouselMode: false })

        // this.dismissOverlay()
      })

      this.animateCSS(this.gradient, "fadeOutDown", () => {
        console.log("fadeOutLeft complete")
        this.setState({ carouselMode: false })
      })
    } else {
      this.animateCSS(this.carousel, "fadeInLeft", () => {
        console.log("fadeInLeft complete")
        this.setState({ carouselMode: true })

        // this.dismissOverlay()
      })

      this.animateCSS(this.gradient, "fadeInUp", () => {
        console.log("fadeOutLeft complete")
        this.setState({ carouselMode: false })
      })
    }
  }

  handleClick = (e) => {
    console.log("handleClick")
  }

  handlePlayPause = () => {
    this.setState({ playing: !this.state.playing })
    // console.log('TakkoPlayer.jsx handlePlayPause ' + this.state.playing)
  }

  setPlaying = (playing) => {
    this.setState({ playing })
  }

  handleProgress = state => {
    // We only want to update time slider if we are not currently seeking
    // if (!this.state.seeking) {
      // console.log("handleProgress")
      this.props.handleProgress(state)
    // }
  }

  handleDuration = (duration) => {
    // console.log('onDuration', duration)
    this.setState({ duration })
  }

  pause = (e) => {
    !isEmpty(e) && e.preventDefault()
    console.log("pause()")
    // this.setState({ playing: false })
    // this.ref.playing = false
    if (this.player) {
     this.player.getInternalPlayer().pause()
    }
  }

  play = (e) => {
    !isEmpty(e) && e.preventDefault()
    console.log("play()")
    // this.setState({ playing: true })
    // this.ref.playing = true
    if (this.player) {
      this.player.getInternalPlayer().play()
    }
  }

  onPlayEvent = () => {
    this.setState({ playing: !this.state.playing })
    // console.log('TakkoPlayer.jsx handlePlayPause ' + this.state.playing)
  }

  validateSource = (selectedPost) => {
    return ReactPlayer.canPlay(selectedPost.master_playlist)
  }

  // determine if url is playable
  getSource = (url) => {
    var getHeaders = {
      headers: {}
    }
    axios.get(url, getHeaders)
      .then(response => {
        const result = response.data

        // console.log("getSource: result - ")
        // console.log(result)
        return true
      })
      .catch(error => {
        // console.error("getSource error: " + error)
        return false
      })
  }

  updateSourceState = (selectedPost, hls = true) => {
    const validateSource = this.getSource(selectedPost.master_playlist)

    updateEventSelectedPost(selectedPost)

    if (hls && validateSource) {
      this.setState({ selectedPost: selectedPost, source: selectedPost.master_playlist, played: 0 })
    } else {
      this.setState({ selectedPost: selectedPost, source: selectedPost.media_file_url, played: 0 })
    }
  }

  updateItemsState = (items, page, total_pages) => {
    this.setState({
      items: [
        ...this.state.items,
        ...items
      ],
      page: page,
      total_pages: total_pages,
      lastItemVisible: false,
    })
  }

  updatelastItemVisible = (lastItemVisible, translate) => {
    if (this.state.lastItemVisible != lastItemVisible) {
      this.setState({ lastItemVisible })
      this.CarouselScreen.syncTranslate(translate)
      return true
    }
    return false
  }

  onPostEnded = () => {
    console.log("onPostEnded")
    this.CarouselScreen.carouselNext()
  }

  ref = player => {
    this.player = player
  }

  render() {

    const width = this.props.width
    const iconsWidth = Math.round(width/19)
    const iconsHeight = Math.round(width/19)
    const spacing = width/20

    return (
      <React.Fragment>
        <div className={styles.tortillaWrap}>

          <a href="#" onClick={ (e) => this.toggleMute(e) } className={styles.muteButton} style={{ top: spacing, right: spacing }}>
            <div
              className={this.state.muted ? cx(styles.icons, styles.active) : styles.icons}
              style={{ backgroundImage: `url('${imagePath('post-unmute-icon.png')}`, width: Math.round(iconsWidth*1.1), height: iconsHeight }}>
            </div>

            <div
              className={this.state.muted ? styles.icons : cx(styles.icons, styles.active)}
              style={{ backgroundImage: `url('${imagePath('post-mute-icon.png')}`, width: Math.round(iconsWidth*1.1), height: iconsHeight }}>
            </div>
          </a>

          <div className={styles.videoScreen}
               onClick={() => this.props.toggleCarouselMode()}
               style={{ height: this.props.height, borderRadius: this.props.borderRadius }}>

            <ReactPlayer
              ref={this.ref}
              url={this.state.source}
              playing={this.state.playing}
              loop={false}
              volume={null}
              muted={this.state.muted}
              playbackRate={1}
              playsinline={true}
              width='100%'
              height='100%'
              onReady ={ (e) => {
                // console.log("onReady")

                // updatePlaying(false)
                // this.props.updatePlayingItems(false)
                // this.play()
              }}
              onStart={ () => {
                // console.log("onStart")

                trackEvent('start')
                updatePlaying(true)
                this.props.updatePlayingItems(true)
              }}
              onPlay={ () => {
                // console.log("onPlay")

                trackEvent('play')
                updatePlaying(true)
                this.props.updatePlayingItems(true)
              }}
              onPause={ () => {
                // console.log("onPause")

                trackEvent('pause')
                updatePlaying(false)
                this.props.updatePlayingItems(false)
              }}
              onEnded={ () => {
                // console.log("onEnded")
                this.props.onPostEnded()
              }}
              onBuffer={ () => {
                // console.log("onBuffer")
                trackEvent('buffering_start')
              }}
              onBufferEnd={ () => {
                // console.log("onBufferEnd")
                trackEvent('buffering_end')
              }}
              onProgress={this.handleProgress}
              onDuration={this.handleDuration}
              onSeek={this.state.seeking}
              onError={(e, data) => {
                // this.onError(e, data)
                // console.log("onError: " + data)
                if (!isEmpty(data)) {
                  if (data && data.type == "networkError") {
                    // reset and fallback if needed
                    this.updateSourceState(this.state.selectedPost, false)
                  }
                }
              }}
              progressInterval={100}
              controls={false}
              id={styles.takkoPlayer}
              playsinline={true}
              config={{
                file: {
                  forceHLS: false,
                  hlsOptions: {
                    forceHLS: false,
                    debug: false,
                  },
                },
              }}
            />

          </div>

        </div>
      </React.Fragment>
    )
  }
}
