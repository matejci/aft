
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

import { easeBackInOut, easeBounceInOut } from 'd3-ease'

import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import ScrollContainer from 'react-indiana-drag-scroll'
import { useScrollBoost } from 'react-scrollbooster'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

var setCarouselModeExternal = null
var carouselModeExternal = true

const updateGradientCarouselMode = () => {
  if (setCarouselModeExternal) {
    setCarouselModeExternal(!carouselModeExternal)
  } else {
    // try again
    updateGradientCarouselMode()
  }
}

const Gradient = ({ innerRef, ...props }) => {

  const { borderRadius } = props

  const [ref, bounds] = useMeasure()

  const width = Math.round(bounds.width)
  const height = Math.round(bounds.height)

  const [carouselMode, setCarouselMode] = useState(true)
  // const [styles, api] = useSpring(() => ({ opacity: carouselMode ? 1 : 0 }))
  const animatedStyles = useSpring({
    // from: { opacity: 1, top: 0 },
    // to: { opacity: 0, top: height },
    from: { top: 0 },
    to: {top: height },
    reverse: carouselMode,
    config: {
      duration: 600,
      easing: easeBackInOut.overshoot(1.7)
    },
    // onRest: () => {
    //   console.log('onRest')
    // },
  })

  React.useEffect(() => {
    /* Assign update to outside variable */
    setCarouselModeExternal = setCarouselMode
    carouselModeExternal = carouselMode

    setCarouselMode(carouselMode)

    return () => {
      setCarouselModeExternal = null
    }

  }, [carouselMode])

  return (
    <div ref={mergeRefs([ref, innerRef])}
         className={styles.gradient}
         onClick={ () => props.toggleCarouselMode() }
         style={{ borderBottomLeftRadius: borderRadius, borderBottomRightRadius: borderRadius }}
    >
      <animated.div
        style={animatedStyles}
        className={styles.animatedGradient}
      >
      </animated.div>
    </div>
  )
}

export { Gradient, updateGradientCarouselMode }
