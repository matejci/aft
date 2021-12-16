
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Spring } from 'react-spring/renderprops'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import useMeasure from 'react-use-measure'

import ReactPlayer from 'react-player'
import VideoCover from 'react-video-cover'

import PlayCircleFilledRounded from '@material-ui/icons/PlayCircleFilledRounded'
import PauseCircleFilledRounded from '@material-ui/icons/PauseCircleFilledRounded'

import ScrollMenu from 'react-horizontal-scrolling-menu'
import CarouselScreen from './CarouselScreen'
import PlayedProgressBar from './ProgressBar'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'
import '!style-loader!css-loader!animate.css'

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
      muted: false,
      loaded: 0,
      playbackRate: 1.0,
      source: selectedPost ? selectedPost.master_playlist : "",
      duration: 0,
      carouselMode: true,
      overlay: true,
      postHover: false,
      lastItemVisible: false,
    }

    this.carousel = React.createRef()
    this.gradient = React.createRef()
    this.overlay = React.createRef()

    this.showOverlay = this.showOverlay.bind(this)
    this.hideOverlay = this.hideOverlay.bind(this)
    this.dismissOverlay = this.dismissOverlay.bind(this)

    this.toggleCarouselMode = this.toggleCarouselMode.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.handlePlayPause = this.handlePlayPause.bind(this)
    this.pause = this.pause.bind(this)
    this.play = this.play.bind(this)
    this.handleDuration = this.handleDuration.bind(this)

    this.onPostEnded = this.onPostEnded.bind(this)
    this.updateSourceState = this.updateSourceState.bind(this)
    this.updateItemsState = this.updateItemsState.bind(this)
    this.updatelastItemVisible = this.updatelastItemVisible.bind(this)
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

  UNSAFE_componentWillMount() {
    this.timeoutID = this.dismissOverlay // cache the timeoutID
  }

  componentDidMount() {
    console.log("class TakkoPlayer componentDidMount")

    this.dismissOverlay()
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

  handleProgress = state => {
    // console.log('onProgress', state)
    // We only want to update time slider if we are not currently seeking
    if (!this.state.seeking) {
      // this.setState(state)
      this.ProgressBar.updateProgress(state.played)
    }
  }

  handleDuration = (duration) => {
    // console.log('onDuration', duration)
    this.setState({ duration })
  }

  pause = (e) => {
    !isEmpty(e) && e.preventDefault()
    this.setState({ playing: false })
  }

  play = (e) => {
    !isEmpty(e) && e.preventDefault()
    this.setState({ playing: true })
  }

  onPlayEvent = () => {
    this.setState({ playing: !this.state.playing })
    // console.log('TakkoPlayer.jsx handlePlayPause ' + this.state.playing)
  }

  updateSourceState = (item, translate) => {
    this.setState({ selectedPost: item, source: item.master_playlist, played: 0 })
    this.CarouselScreen.syncTranslate(translate)
    this.play()

    console.log("updateSourceState")
    console.log(typeof(this.props.syncSelectedPost) === 'function')
    if (typeof(this.props.syncSelectedPost) === 'function') {
      this.props.syncSelectedPost(item)
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

    // const PlayPauseScreen = () => {

    //   return (
    //     <React.Fragment>
    //       <Spring
    //         from={{opacity: 0}}
    //         to={{opacity: 1}}
    //         reverse={!this.state.overlay}
    //         // opacity={this.state.overlay ? 1 : 0}
    //         // style={{width: this.props.width, height: this.props.height }}
    //       >
    //         { styles => (
    //           <animated.div style={styles}>
    //             <div ref={this.overlay}
    //                 // className={styles.playPauseScreen}
    //                  className={this.state.overlay ? styles.playPauseScreen : cx(styles.playPauseScreen, styles.hidden)}
    //                  // style={{position: 'relative', width: this.props.width, height: this.props.height, ...styles }}
    //                  style={{width: this.props.width, height: this.props.height }}
    //             >
    //               this.state.overlay { JSON.stringify(this.state.overlay) }
    //               { this.state.playing ? (
    //                 <React.Fragment>
    //                   <a href="#" onClick={ (e) => this.pause(e) } className={styles.playPauseLink}>
    //                     <PauseCircleFilledRounded className={styles.pauseIcon} />
    //                   </a>

    //                   <div onClick={ () => this.toggleCarouselMode() } className={styles.playPauseBg}></div>
    //                 </React.Fragment>
    //               ) : (
    //                 <React.Fragment>
    //                   <a href="#" onClick={ (e) => this.play(e) } className={styles.playPauseLink}>
    //                     <PlayCircleFilledRounded className={styles.playIcon} />
    //                   </a>

    //                   <div onClick={ () => this.toggleCarouselMode() } className={styles.playPauseBg}></div>
    //                 </React.Fragment>
    //               )}
    //             </div>
    //           </animated.div>
    //         )}
    //       </Spring>

    //     </React.Fragment>
    //   )
    // }

    const PlayPauseScreen = () => {

      return (
        <React.Fragment>
          <div ref={this.overlay}
               className={this.state.overlay ? styles.playPauseScreen : cx(styles.playPauseScreen, styles.hidden)}
               style={{width: this.props.width, height: this.props.height }}
          >
            { this.state.playing ? (
              <React.Fragment>
                <a href="#" onClick={ (e) => this.pause(e) } className={styles.playPauseLink}>
                  <PauseCircleFilledRounded className={styles.pauseIcon} />
                </a>

                <div onClick={ () => this.toggleCarouselMode() } className={styles.playPauseBg}></div>
              </React.Fragment>
            ) : (
              <React.Fragment>
                <a href="#" onClick={ (e) => this.play(e) } className={styles.playPauseLink}>
                  <PlayCircleFilledRounded className={styles.playIcon} />
                </a>

                <div onClick={ () => this.toggleCarouselMode() } className={styles.playPauseBg}></div>
              </React.Fragment>
            )}
          </div>
        </React.Fragment>
      )
    }

    return (
      <React.Fragment>
        <div className={styles.tortillaWrap}>

          <div className={styles.videoScreen}
                onMouseEnter={ () => {
                  this.setState({ postHover: true })
                    this.showOverlay()
                  }
                }
                onMouseLeave={ () => {
                  this.setState({ postHover: false })
                  this.hideOverlay()
                  }
                }
                style={{ height: this.props.height, borderRadius: this.props.borderRadius }}>

            <PlayPauseScreen />

            <ReactPlayer
              ref={this.ref}
              url={this.state.source}
              playing={this.state.playing}
              loop={false}
              volume={null}
              playbackRate={1}
              playsinline={true}
              width='100%'
              height='100%'
              onPlay={ () => {
                console.log("onPlay")
                console.log("playing: " + this.state.playing)
                this.dismissOverlay()
              }}
              onPause={ () => {
                console.log("onPause")
                console.log("playing: " + this.state.playing)
              }}
              onEnded={ () => {
                console.log("onEnded")
                this.onPostEnded()
              }}
              onProgress={this.handleProgress}
              onDuration={this.handleDuration}
              progressInterval={100}
              controls={false}
              id={styles.takkoPlayer}
            />

            <div ref={this.gradient}
                 onClick={ () => this.toggleCarouselMode() }
                 className={this.state.carouselMode ? styles.gradient : cx(styles.gradient, styles.hidden)}
                 style={{ borderBottomLeftRadius: this.props.borderRadius*0.95, borderBottomRightRadius: this.props.borderRadius*0.95 }}
            ></div>

            <div ref={this.carousel}
                 onMouseEnter={ () => this.hideOverlay() }
                 onMouseLeave={ () => this.showOverlay() }
                 className={this.state.carouselMode ? styles.carousel : cx(styles.carousel, styles.hidden)} >
              { (this.state.items) && (
                <CarouselScreen
                  ref={instance => { this.CarouselScreen = instance }}
                  play={this.play}
                  pause={this.pause}
                  page={this.state.page}
                  total_pages={this.state.total_pages}
                  items={this.state.items}
                  selectedPost={this.state.selectedPost}
                  updateSourceState={this.updateSourceState}
                  updateItemsState={this.updateItemsState}
                  originalPost={this.props.post}
                  lastItemVisible={this.state.lastItemVisible}
                  updatelastItemVisible={this.updatelastItemVisible}
                />
              )}
            </div>
          </div>

          <PlayedProgressBar ref={instance => { this.ProgressBar = instance }} />

          {/*<ProgressBar
            completed={this.state.played*100}
            isLabelVisible={false}
            transitionDuration={'0.5s'}
            height={'5px'}
            bgColor={'rgba(118, 70, 254, 0.2)'}
            baseBgColor={'rgba(255,255,255,0.05)'}
            transitionTimingFunction={'ease-in'}
          />*/}

        </div>
      </React.Fragment>
    )
  }
}