
import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css
import { format } from 'date-fns'
import debounce from 'lodash.debounce'

import Item from './Item'
import { CarouselCard } from './CarouselCard'

import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import ScrollContainer from 'react-indiana-drag-scroll'
import { useScrollBoost } from 'react-scrollbooster'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

var carouselEnd = false
var scrollObject = null
var setItemsExternal = null
var setSelectedExternal = null
var setProgressExternal = null
var setPlayingExternal = null
var setPageExternal = null
var setTotalPagesExternal = null
var setLoadingExternal = null
var loadingExt = false
var selectedPost = {}
var itemsExternal = []
var refresh = false
var pageExternal = 1
var totalPagesExternal = null
var elementExternal = {}

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

const Loading = (props) => {
	const { size } = props

  return (
    <div {...props} className={styles.spinnerLoading}>
      <div className={styles.spinner} style={{ width: size, height: size }}>
        <div className={styles.doubleBounce1}></div>
        <div className={styles.doubleBounce2}></div>
      </div>
      <p>{props.message}</p>
    </div>
  )
}

const CarouselScrollNode = () => {
	console.log('CarouselScrollNode')

	return scrollObject
}

const getIndex = (id) => {
  return itemsExternal.length > 0 ? itemsExternal.findIndex(obj => obj.id === id) : null
}

const getSelectedPost = (id, items) => {
  return itemsExternal.length > 0 ? itemsExternal.find((item)=> item.id == id ) : {}
}

const carouselNext = () => {
  // console.log("carouselNext")

  // if (isEmpty(selectedPost)) { return } // selectedPost guard

  var postIndex = getIndex(selectedPost.id)
  // console.log("carouselNext postIndex")
  // console.log(postIndex)

  var nextIndex = postIndex+1
  var nextItem = itemsExternal[nextIndex]

  if (nextIndex < itemsExternal.length) {
    // select next item in carousel
    updateSelected(nextItem.id)

    return nextItem
  } else {
    // loop
    // console.log("loop")
    // if (itemsExternal.length == 0) { return } // itemsExternal empty array guard

    var firstItem = itemsExternal[0]

    // scroll to the beginning of the carousel
    if (scrollObject) {
    	const scrollState = scrollObject.getState()
    	scrollObject.scrollTo({ x: 0, y: 0 })
    }

    updateSelected(firstItem.id)
    return firstItem
  }
}

const updateSelected = (selected) => {
	// console.log('updateSelected')

	if (setSelectedExternal) {
		setSelectedExternal(selected)
	} else {
		// try again
		updateSelected(selected)
	}
}

const updateItems = (items) => {
	// console.log('updateItems')

	carouselEnd = true
	refresh = true

	if (setItemsExternal) {
		const ARRAY_LENGTH = 2
		var newItems = Array.from({length: ARRAY_LENGTH}, (_, i) => i + 1)
		setItemsExternal([])

		if (scrollObject) {
			console.log("scrollObject updateItems")

			setItemsExternal(newItems)
			carouselEnd = true
			refresh = false
  	}
	} else {
		// try again
		updateItems(items)
	}
}

const appendItems = (items) => {
	if (items.length == 0) { return } // guard for empty appended items
	// console.log('appendItems')

	carouselEnd = true
	refresh = true

	if (setItemsExternal) {
		// const ARRAY_LENGTH = 2
		// var newItems = Array.from({length: ARRAY_LENGTH}, (_, i) => i + 1)
		
		if (scrollObject) {
			// console.log("scrollObject updateItems")
			// setItemsExternal([])

			// setItemsExternal(newItems)
			setItemsExternal( (prevItems) => {
				const ARRAY_LENGTH = 10
				var newItems = Array.from({length: ARRAY_LENGTH}, (_, i) => i + prevItems.length + 1)
				// console.log('items.length: ' + prevItems.length)

				return ([...prevItems, ...items])
			})

			carouselEnd = true
			refresh = false

			scrollObject.updateMetrics()
			// console.log("scrollObject.getState()")
			const scrollState = scrollObject.getState()
			// console.log(scrollState)

			// guard if user is dragging the carousel
			if (!scrollState.isDragging) {
				// animate scroll peak to new contents
				scrollObject.scrollTo({ x: scrollState.position.x+30, y: scrollState.position.y })
			}
  	}
	} else {
		// try again
		console.log("scrollObject try again")
		appendItems(items)
	}
}

const updateProgress = (progress) => {
	// console.log('updateProgress')

	if (setProgressExternal) {
		setProgressExternal(progress)
	} else {
		// try again
		updateProgress(progress)
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

const getTakkos = (element) => {
  const nextPage = pageExternal+1

  if (totalPagesExternal !== null) {
  	if (nextPage > totalPagesExternal) {
    	// this.endOfTakkosAlert()
    	// console.log(`nextPage > totalPagesExternal ${JSON.stringify(totalPagesExternal)} : END`)
    	if (setLoadingExternal) {
	  		setLoadingExternal(false)
	  	}
    	return
 	 	}
  }
  // console.log(`nextPage ${JSON.stringify(nextPage)} | totalPagesExternal ${JSON.stringify(totalPagesExternal)}`)

  if (setLoadingExternal) {
		setLoadingExternal(true)
	}

  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  var getHeaders = {
    headers: {
      'X-CSRF-Token': csrfToken,
      'HTTP-X-APP-TOKEN': appToken,
      'APP-ID': appId
    }
  }

  // get item
  axios.get(`/posts/`+element.parent_id+`/takkos.json?per_page=`+ 7 +`&page=`+ nextPage, getHeaders)
    .then(response => {
      const data = response.data
      const takkos_count = response.data.takkos_count
      // this.setState({ post: item })

      pageExternal = nextPage
      totalPagesExternal = data.total_pages

      setPageExternal(nextPage)
      setTotalPagesExternal(totalPagesExternal)

      appendItems(data.data.items)

      if (setLoadingExternal) {
		  	setLoadingExternal(false)
		  }

      // console.log("getTakkos data: ")
      // console.log(data)

      // console.log("takkos_count: ")
      // console.log(takkos_count)


      // this.props.updateItemsState(data.data.items, nextPage, data.total_pages)

    })
    .catch(error => {
      console.error("error: " + error)
      console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
      // this.setState({ errors: error.response.data })
      setLoadingExternal(false)
    })
}








const CarouselScroll = ({ innerRef, children, ...props }) => {

	const [items, setItems] = useState(refresh ? [] : props.items)
	const [element, setElement] = useState(props.element)
	const [selected, setSelected] = useState(props.element.selected_id)
	const [progress, setProgress] = useState(0)
	const [playing, setPlaying] = useState(false)
	const [page, setPage] = useState(1)
	const [totalPages, setTotalPages] = useState(1)
	const [loading, setLoading] = useState(false)

	// emmulate componentDidMount lifecycle
	/*
  React.useEffect(() => {
    setItems(props.items)
  }, [])
  */

  React.useEffect(() => {
  	/* Assign update to outside variable */
    setItemsExternal = setItems
    setSelectedExternal = setSelected
    setProgressExternal = setProgress
    setPlayingExternal = setPlaying
    setPageExternal = setPage
    setTotalPagesExternal = setTotalPages
    // setLoadingExternal = setLoading

  	setItems(items)
  	itemsExternal = items
  	elementExternal = element
  	// loadingExt = loading
  	// setLoading(loading)
  	setPage(page)
  	setTotalPages(totalPages)
  	selectedPost = getSelectedPost(selected, items)
  	if (scrollbooster) {
  		scrollbooster.updateMetrics()
  	}

  	return () => {
  		// console.log("useEffect cleanup")
  		setItemsExternal = null
  		setSelectedExternal = null
  		setProgressExternal = null
  		setPlayingExternal = null
  		selectedPost = {}
  		itemsExternal = []
  		elementExternal = {}
  		setPageExternal = null
			setTotalPagesExternal = null
			// setLoadingExternal = null
  	}

  }, [items, selected, progress, playing, page, totalPages])

  React.useEffect(() => {
  	/* Assign update to outside variable */
    setLoadingExternal = setLoading

  	loadingExt = loading
  	setLoading(loading)

  	if (scrollbooster) {
  		scrollbooster.updateMetrics()
  	}

  	return () => {
			setLoadingExternal = null
			debounceGetTakkos.cancel
  	}

  }, [loading])

  React.useEffect(() => {

  	setProgress(0)

  }, [selected])

  const debounceGetTakkos = useCallback( debounce( () => {
		carouselEnd = true
		getTakkos(element)
	}, 1000, {
		'leading': true,
		'trailing': false,
	}), [loading])

  const [viewport, scrollbooster] = useScrollBoost({
      direction: 'horizontal',
      friction: 0.05,
      scrollMode: 'transform',
      emulateScroll: false,
      onUpdate: (state) => {
		    // state contains useful metrics: position, dragOffset, dragAngle, isDragging, isMoving, borderCollision
		    onUpdate(state)

		    // content.style.transform = `translate(
		    //   ${-state.position.x}px,
		    //   ${-state.position.y}px
		    // )`
		  },
  })

  scrollObject = scrollbooster

  const onUpdate = (state) => {
  	if (refresh) { return }

  	if (state.borderCollision.right) {
	  	if (carouselEnd) {
	  		// ignore
	  	} else {

		    const scrollPosition = Math.round(state.position.x)
	  		if (scrollPosition > 10 && loading == false) {
	  			debounceGetTakkos()
	  		}
	  		
	  		// const currentDate = format(Date.now(), 'yyyy-MM-dd hh:mm:ssaaa xxxx')
	  		// console.log('end of carousel - state.position ' + JSON.stringify(currentDate))
		    // console.log(Math.round(state.position.x))

				// getTakkos(element)
	  	}
	  } else {
	  	carouselEnd = false
	  }
  }

  const borderWidth = Math.round(props.width/20)
  const loadingWidth = loading ? props.width*0.7 : borderWidth*2

  return (
    <div ref={viewport} style={{ overflow: 'hidden' }} className={styles.carouselScroll}>
      <div ref={innerRef} className={'content inner-scroll ' + styles.innerScroll} style={{ padding: `0 ${props.innerPadding}px`, columnGap: props.columnGap }}>

    		{items.map( (item, index) => (
          <CarouselCard
          	key={index}
          	item={item}
          	selected={selected}
          	scrollbooster={scrollbooster}
          	randomSync={props.randomSync}
          	updateSelected={updateSelected}
          	updateSourceState={props.updateSourceState}
          	progress={progress}
          	height={props.height}
            width={props.width}
            borderRadius={props.borderRadius}
            borderWidth={borderWidth}
            playing={playing}
            play={props.play}
            pause={props.pause}
          />
        ))}

    		<div className={loading ? cx(styles.carouselLoading, styles.active, styles.item) : cx(styles.carouselLoading, styles.item)}
						style={{
							width: loadingWidth,
							minWidth: loadingWidth,
							height: props.height,
							borderRadius: props.borderRadius,
							borderWidth: borderWidth
						}}
					>
      		<Loading size={props.width*0.5} />
      	</div>
        
      	{/*{ children(scrollbooster) }*/}

      </div>
    </div>
	)
}

export { CarouselScroll, CarouselScrollNode, carouselNext, updateItems, updateSelected, updateProgress, updatePlaying }
