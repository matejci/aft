
import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { useSpring, animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import { easeBackInOut, easeBounceInOut } from 'd3-ease'

import NumberFormat from 'react-number-format'
import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import { CarouselTop, updateSelectedPost } from './CarouselTop'
import { CarouselScroll, CarouselScrollNode, carouselNext, updateItems, updateSelected, updateProgress, updatePlaying } from './CarouselScroll'
import Item from './Item'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

var scrollboosterObject = null
var setCarouselModeExternal = null
var carouselModeExternal = true

export default class Carousel extends React.Component {

  constructor(props) {
    super(props)

    const ARRAY_LENGTH = 10
    this.itemsArray = Array.from({length: ARRAY_LENGTH}, (_, i) => i + 1)

    this.state = {
      items: [],
      selectedPost: {},
      random: false,
      scrollPosition: 0,
      itemsArray: this.itemsArray,
      carouselEnd: false
    }

    this.scrollWrap = React.createRef()
    // this.CarouselScroll = React.createRef()
    this.CarouselInnerScroll = React.createRef()

    this.updateProgress = this.updateProgress.bind(this)
    this.updateCarouselItems = this.updateCarouselItems.bind(this)
    this.syncSelectedPost = this.syncSelectedPost.bind(this)
    this.randomSync = this.randomSync.bind(this)
    this.getIndex = this.getIndex.bind(this)
    this.carouselNext = this.carouselNext.bind(this)
    this.syncItems = this.syncItems.bind(this)
    this.scrollInfo = this.scrollInfo.bind(this)
    this.scrollTo = this.scrollTo.bind(this)
    this.updatePlayingItems = this.updatePlayingItems.bind(this)
    this.updateCarouselMode = this.updateCarouselMode.bind(this)
  }

  componentDidMount() {
    console.log("class Carousel componentDidMount")
  }

  componentWillUnmount() {
    console.log("class Carousel componentWillUnmount")
  }

  updateProgress = (played) => {
    updateProgress(played)
  }

  updateCarouselItems() {
    // console.log("updateCarouselItems")
    // updateItems()
  }

  syncSelectedPost(selectedPost) {
    // console.log("syncSelectedPost")

    updateSelectedPost(selectedPost)

  }

  randomSync = (e, item) => {
    e.preventDefault()

    // console.log("Carousel.jsx randomSync")
    console.log("Carousel.jsx randomSynced: " + item)

    console.log(this.CarouselScroll)

    console.log("CarouselScroll scrollInfo")
    const scrollWrap = this.CarouselScroll.current
    const scrollWidth = scrollWrap.scrollWidth
    const clientWidth = scrollWrap.clientWidth

    const scrollEndOffset = 0
    const scrollEnd = scrollWidth-clientWidth-scrollEndOffset

    const scrollPosition = scrollWrap.scrollLeft

    console.log(`scrollLeft: ${scrollPosition}, scrollEnd: ${scrollEnd}`)

    // this.setState({ random: !this.state.random })
  }

  getIndex = (post) => {
    return this.state.items.findIndex(obj => obj.id === post.id)
  }

  carouselNext = () => {
    const nextItem = carouselNext()
    this.props.updateSourceState(nextItem)
  }

  syncItems = (items) => {
    console.log("Carousel.jsx syncItems")

    // this.itemsArray = [...this.itemsArray, ...items]
    // console.log(this.itemsArray)

    // const sb = this.CarouselScroll
    // console.log("syncItems: this.CarouselScroll")
    // console.log(sb)

    // var scrollNode = CarouselScrollNode()

    // console.log(scrollNode)

    // scrollNode.scrollTo({ x: 100, y: 0 })

    // var scrollPosition = scrollNode.getState().position.x
    // console.log('scrollNode.getState.position ' + Math.round(scrollPosition))
    // this.setState({ random: !this.state.random })
    // scrollNode.setPosition({ x: scrollPosition, y: 0 })

    // this.setState({ itemsArray: items })
    /*
    this.setState({
      itemsArray: [
        ...this.state.itemsArray,
        ...items
      ],
      // lastItemVisible: false,
    }, () => {
      console.log('this.syncItems SET ' + Date.now())
      console.log(this.state.itemsArray)
    })
    */

    // scrollNode.setPosition({ x: scrollPosition, y: 0 })
  }

  scrollInfo = () => {
    console.log("scrollInfo")
    const scrollWrap = this.scrollWrap.current
    const scrollWidth = scrollWrap.scrollWidth
    const clientWidth = scrollWrap.clientWidth

    const scrollEndOffset = 0
    const scrollEnd = scrollWidth-clientWidth-scrollEndOffset

    const scrollPosition = scrollWrap.scrollLeft

    console.log("this.scrollWrap ")
    console.log(this.scrollWrap)
    console.log(`scrollLeft: ${scrollPosition}, scrollEnd: ${scrollEnd}`)
  }

  scrollTo = (position) => {
    console.log("scrollTo")
    const scrollWrap = this.scrollWrap.current
    const scrollWidth = scrollWrap.scrollWidth
    const clientWidth = scrollWrap.clientWidth

    const scrollEndOffset = 0
    const scrollEnd = scrollWidth-clientWidth-scrollEndOffset

    const scrollPosition = scrollWrap.scrollLeft

    // scrollHeight: 159
    // scrollLeft: 980
    // scrollTop: 0
    // scrollWidth: 1510

    scrollWrap.scrollTo(position, 0)
  }

  updateCarouselMode = () => {
    if (setCarouselModeExternal) {
      setCarouselModeExternal(!carouselModeExternal)
    } else {
      // try again
      this.updateCarouselMode()
    }
  }

  updatePlayingItems = (playing) => {
    updatePlaying(playing)
  }


  render() {
    const element = this.props.element
    const items = element ? element.items : []
    const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    const CarouselBox = () => {
      const [ref, bounds] = useMeasure()
      const [carouselRef, carouselBounds] = useMeasure()

      const [carouselMode, setCarouselMode] = useState(true)

      const widthParent = Math.round(bounds.width)
      const heightParent = Math.round(bounds.height)
      const widthCarousel = Math.round(carouselBounds.width)
      const heightCarousel = Math.round(carouselBounds.height)

      const animatedStyles = useSpring({
        from: { bottom: 0 },
        to: {bottom: -(heightCarousel*1.25) },
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

      const height = heightParent
      const width = (9/16)*height
      const horizontalPadding = heightParent/5
      const bottomPadding = heightParent/25
      const borderRadius = width/6

      const iconsWidth = heightParent/7
      const iconsHeight = heightParent/7
      const iconsFontSize = heightParent/12

      const innerPadding = (bounds.width < 767) ? heightCarousel/15 : heightCarousel/20
      const columnGap = (bounds.width < 767) ? heightCarousel/45 : heightCarousel/30
      const fontSize = (bounds.width < 767) ? bounds.height/10.5 : bounds.height/11

      return (
        <animated.div style={{ ...animatedStyles,...{ padding: `0 0 ${innerPadding}px 0` } }} ref={carouselRef} className={styles.carousel}>

          <CarouselTop
            widthParent={widthParent}
            heightParent={heightParent}
            iconsWidth={iconsWidth}
            iconsHeight={iconsHeight}
            iconsFontSize={iconsFontSize}
            fontSize={fontSize}
            selectedPost={selectedPost}
          />
          <div ref={ref} className={styles.carouselWrap}>
            <CarouselScroll
              innerRef={this.CarouselInnerScroll}
              element={this.props.element}
              items={this.props.items}
              syncItems={this.syncItems}
              height={height}
              width={width}
              borderRadius={borderRadius}
              innerPadding={innerPadding}
              columnGap={columnGap}
              play={this.props.play}
              pause={this.props.pause}
              updateSourceState={this.props.updateSourceState}
            />
          </div>

        </animated.div>
      )
    }

    return (
      <React.Fragment>

        <CarouselBox />

      </React.Fragment>
    )
  }

}
