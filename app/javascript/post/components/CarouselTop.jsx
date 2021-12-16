
import React, { useState, useEffect, useRef, useCallback } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css
import { format } from 'date-fns'
import NumberFormat from 'react-number-format'

import useMeasure from 'react-use-measure'
import mergeRefs from 'react-merge-refs'

import ScrollContainer from 'react-indiana-drag-scroll'
import { useScrollBoost } from 'react-scrollbooster'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

var setSelectedPostExternal = null

const updateSelectedPost = (selectedPost) => {
	console.log('updateSelectedPost')

	if (setSelectedPostExternal) {
		setSelectedPostExternal(selectedPost)
	} else {
		// try again
		updateSelectedPost(selectedPost)
	}
}

const callToAction = (e) => {
  e.preventDefault()

  // redirect to app store
  console.log("callToAction")

  const url = 'https://apple.co/3w65qgG'
  const win = window.open(url, '_blank')
  if (win != null) {
    win.focus()
  }
}

function nFormatter(num, digits=2) {
  const lookup = [
    { value: 1, symbol: '' },
    { value: 1e3, symbol: 'k' },
    { value: 1e6, symbol: 'M' },
    { value: 1e9, symbol: 'G' },
    { value: 1e12, symbol: 'T' },
    { value: 1e15, symbol: 'P' },
    { value: 1e18, symbol: 'E' }
  ];
  const rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
  var item = lookup.slice().reverse().find(function(item) {
    return num >= item.value;
  });
  return item ? (num / item.value).toFixed(digits).replace(rx, '$1') + item.symbol : '0';
}

const CarouselTop = ({ innerRef, ...props }) => {

	const [selectedPost, setSelectedPost] = useState(props.selectedPost)

	const { widthParent, heightParent, iconsWidth, iconsHeight, iconsFontSize, fontSize } = props

  React.useEffect(() => {
  	/* Assign update to outside variable */
    setSelectedPostExternal = setSelectedPost

  	setSelectedPost(selectedPost)

  	return () => {
  		setSelectedPostExternal = null
  	}

  }, [selectedPost])

  return (
    <div ref={innerRef} className={styles.carouselInfo} style={{ marginBottom: iconsHeight/3 }}>
      <div className={styles.postViews} style={{fontSize: fontSize*0.8}}>
				<img style={{height: fontSize*0.65}} src={imagePath('view-icon.svg')}/>
        <NumberFormat
					value={selectedPost.counted_watchtime}
					displayType={'text'}
					decimalScale={0}
					renderText={(value, props) =>
						<p style={{marginRight: fontSize/4, marginLeft: fontSize/4}} {...props}>{nFormatter(value)}</p>
					}
				/>
				<p>sec</p>
      </div>

      <div className={styles.postTitle} style={{ margin: `${heightParent/50}px 0 0 0` }}>
        <h1 style={{ fontSize: fontSize }}>{ selectedPost.title }</h1>
      </div>

      <div className={styles.postMetrics} style={{ margin: `${heightParent/10}px 0 0 0` }}>
        <div className={styles.leftCol}>
          <div className={styles.votes} style={{ columnGap: heightParent/11 }}>
            <a href="#" onClick={ (e) => callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-upvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            <NumberFormat value={selectedPost.upvotes_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
            <a href="#" onClick={ (e) => callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-downvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
          </div>
        </div>

        <div className={styles.rightCol}>
          <div className={styles.postActions} style={{ columnGap: heightParent/9 }}>
            <a href="#" onClick={ (e) => callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-ellipsis-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
            <a href="#" onClick={ (e) => callToAction(e) } className={styles.postActionsLinkGroup}>
              <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-comments-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div>
              <div className={styles.metric}><NumberFormat value={selectedPost.comments_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} /></div>
            </a>
            <a href="#" onClick={ (e) => callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-add-takko-icon.png')}`, minWidth: iconsWidth*1.2, height: iconsHeight }}></div></a>
          </div>
        </div>
      </div>
    </div>
	)
}

export { CarouselTop, updateSelectedPost }
