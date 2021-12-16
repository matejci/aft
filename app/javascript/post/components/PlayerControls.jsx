
import React, { useState, useEffect, useRef, useCallback } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { useSpring, animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css
import { format } from 'date-fns'
import NumberFormat from 'react-number-format'

import { easeBackInOut } from 'd3-ease'

import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import ScrollContainer from 'react-indiana-drag-scroll'
import { useScrollBoost } from 'react-scrollbooster'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

var setSelectedPostExternal = null
var setPlayingExternal = null

var setCarouselModeExternal = null
var carouselModeExternal = true


const updateSelectedPost = (selectedPost) => {
	// console.log('updateSelectedPost')

	if (setSelectedPostExternal) {
		setSelectedPostExternal(selectedPost)
	} else {
		// try again
		updateSelectedPost(selectedPost)
	}
}

const updatePlaying = (playing) => {
  // console.log('updatePlaying')

  if (setPlayingExternal) {
    setPlayingExternal(playing)
  } else {
    // try again
    updatePlaying(playing)
  }
}

const callToAction = (e) => {
  e.preventDefault()

  // redirect to app store
  // console.log("callToAction")

  const url = 'https://apple.co/3w65qgG'
  const win = window.open(url, '_blank')
  if (win != null) {
    win.focus()
  }
}

const updatePlayerControlsCarouselMode = () => {
  if (setCarouselModeExternal) {
    setCarouselModeExternal(!carouselModeExternal)
  } else {
    // try again
    updatePlayerControlsCarouselMode()
  }
}

const PlayerControls = ({ innerRef, ...props }) => {

  const [ref, bounds] = useMeasure()

	const [selectedPost, setSelectedPost] = useState(props.selectedPost)
  const [playing, setPlaying] = useState(props.playing)
  const [carouselMode, setCarouselMode] = useState(true)

  const width = Math.round(bounds.width)
  const height = Math.round(bounds.height)

  const animatedStyles = useSpring({
    from: { bottom: height, opacity: 0 },
    to: { bottom: 0, opacity: 1 },
    reverse: carouselMode,
    config: {
      duration: 500,
      easing: easeBackInOut.overshoot(1.7)
    },
    onRest: () => {
      // console.log('onRest')
    },
  })

  const iconsWidth = width/20
  const iconsHeight = width/20
  const iconsFontSize = width/28
  const columnGap = width/22
  const columnGapGroup = width/26

  const fontSize = (bounds.width < 767) ? bounds.width/11.5 : bounds.width/12

  React.useEffect(() => {
  	/* Assign update to outside variable */
    setSelectedPostExternal = setSelectedPost
    setPlayingExternal = setPlaying
    setCarouselModeExternal = setCarouselMode
    carouselModeExternal = carouselMode

  	setSelectedPost(selectedPost)
    setPlaying(playing)
    setCarouselMode(carouselMode)

  	return () => {
  		setSelectedPostExternal = null
      setPlayingExternal = null
      setCarouselModeExternal = null
  	}

  }, [selectedPost, playing, carouselMode])

  return (
    <animated.div ref={ref} style={animatedStyles} className={styles.playerControls}>

      <div className={styles.postMetrics} style={{ margin: `${columnGap/4}px 0 0 0` }}>
        <div className={styles.leftCol}>
          <div className={styles.votes} style={{ columnGap: columnGapGroup }}>
            <a href="#" onClick={ (e) => callToAction(e) } className={styles.postMetricsLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-upvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            <NumberFormat value={selectedPost.upvotes_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
            <a href="#" onClick={ (e) => callToAction(e) } className={styles.postMetricsLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-downvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
          </div>
        </div>

        <div className={styles.centerCol}>
          <div className={styles.playerToggle}>
            {(playing) ? (
              <a href="#" onClick={ (e) => props.pause(e) } className={styles.postMetricsLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-pause-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            ) : (
              <a href="#" onClick={ (e) => props.play(e) } className={styles.postMetricsLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-play-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            )}
          </div>
        </div>

        <div className={styles.rightCol}>
          <div className={styles.postActions} style={{ columnGap: columnGap }}>
            <a href="#" onClick={ (e) => callToAction(e) } className={styles.postMetricsLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-ellipsis-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            <a href="#" onClick={ (e) => callToAction(e) } className={styles.postActionsLinkGroup}>
              <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-comments-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div>
              <div className={styles.metric}><NumberFormat value={selectedPost.comments_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} /></div>
            </a>
          </div>
        </div>
      </div>
    </animated.div>
	)
}

export { PlayerControls, updateSelectedPost, updatePlaying, updatePlayerControlsCarouselMode }
