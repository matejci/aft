
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

const handleClick = (e, props) => {
  e.preventDefault()

  console.log('Item handleClick')
  console.log('Item handleClicked: ' + props.item.id)

  props.updateSelected(props.item.id)
  props.updateSourceState(props.item)
}

const CarouselCard = ({ innerRef, ...props }) => {

  const [selectedPost, setSelectedPost] = useState(props.selectedPost)

  const item = props.item
  const selectedStatus = (props.selected == item.id)

  const playPauseIconHeight = props.height/6
  const fontSize = Math.round(props.height/12)
  const padding = Math.round(props.height/20)

  const iconsWidth = Math.round(props.height/14)
  const iconsHeight = Math.round(props.height/14)
  const columnGap = Math.round(props.width/30)

  const profileWidth = Math.round(props.width/3)
  const profileBorder = props.height/75
  const border = (profileBorder > 2) ? profileBorder : 2

  const progress = props.progress*100


  React.useEffect(() => {
    /* Assign update to outside variable */
    setSelectedPostExternal = setSelectedPost

    setSelectedPost(selectedPost)

    return () => {
      setSelectedPostExternal = null
    }
    
  }, [selectedPost])

  return (
    <div
      className={selectedStatus ? cx(styles.item, styles.selected) : styles.item}
      style={{width: props.width, minWidth: props.width, height: props.height, borderRadius: props.borderRadius, borderWidth: props.borderWidth}}
    >
      <a href="#" onClick={ (e) => handleClick(e, props) } className={styles.postLink}>
        <div className={styles.itemContent} style={{backgroundImage: "url('" + item.media_thumbnail.thumb.url + "')"}}>

          <div className={selectedStatus ? cx(styles.itemProgressBackground, styles.active) : styles.itemProgressBackground} style={{borderRadius: props.borderRadius}}>
            <div className={styles.itemProgressBar} style={{ width: `${progress}%` }}></div>
          </div>

          {!selectedStatus && (
            <div className={styles.cardInfo}>
              <div className={styles.cardProfile}>
                <div className={cx(styles.profileImage, styles.aspectRatio)} style={{ width: profileWidth, height: profileWidth, backgroundImage: `url('${item.user.profile_thumb_url}`, border: `${border}px solid rgba(255,255,255,1.0)`, margin: `${padding}px ${padding}px 0 0` }}></div>
              </div>

              <div className={styles.cardUpvotes} style={{ bottom: padding, columnGap: columnGap }}>
                <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-upvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div>
                <NumberFormat value={item.upvotes_count} style={{ fontSize: fontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
              </div>
            </div>
          )}

          {!selectedStatus && (
            <div className={styles.cardGradient}></div>
          )}

        </div>
      </a>

      {selectedStatus && (
        <div className={styles.playerToggle}>
          <a href="#" onClick={ (e) => props.pause(e) } className={props.playing ? cx(styles.playerToggleLink, styles.active) : styles.playerToggleLink}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-pause-icon.png')}`, width: playPauseIconHeight, height: playPauseIconHeight }}></div></a>

          <a href="#" onClick={ (e) => props.play(e) } className={props.playing ? styles.playerToggleLink : cx(styles.playerToggleLink, styles.active)}><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-play-icon.png')}`, width: playPauseIconHeight, height: playPauseIconHeight }}></div></a>
        </div>
      )}
    </div>
  )
}

export { CarouselCard }
