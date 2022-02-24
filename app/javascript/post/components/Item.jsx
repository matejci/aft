
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Item extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      progress: 0,
    }

    this.handleClick = this.handleClick.bind(this)
    this.updateProgress = this.updateProgress.bind(this)
    this.updatePlaying = this.updatePlaying.bind(this)
  }

  componentDidMount() {
    console.log("class Item componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (e) => {
    e.preventDefault()

    console.log('Item handleClick')
    console.log('Item handleClicked: ' + this.props.item.id)

    // this.props.randomSync(e, this.props.item)
    // this.props.scrollbooster.scrollTo({ x: 0, y: 0 })

    this.props.updateSelected(this.props.item.id)
  }

  updateProgress = (progress) => {
    this.setState({ progress })
  }

  updatePlaying = (playing) => {
    this.setState({ playing })
  }

  render() {
    const progress = this.props.progress*100

    const item = this.props.item
    const selectedStatus = this.props.selected == item.id

    const playPauseIconHeight = this.props.height/6

    return (
      <div
        className={selectedStatus ? cx(styles.item, styles.selected) : styles.item}
        style={{width: this.props.width, minWidth: this.props.width, height: this.props.height, borderRadius: this.props.borderRadius}}
      >
        <a href="#" onClick={ (e) => this.handleClick(e) } className={styles.postLink}>
          <div className={styles.itemContent} style={{backgroundImage: "url('" + item.media_thumbnail.thumb.url + "')"}}>

            <div className={selectedStatus ? cx(styles.itemProgressBackground, styles.active) : styles.itemProgressBackground}>
              <div className={styles.itemProgressBar} style={{ width: `${progress}%` }}></div>
            </div>

            {selectedStatus && (
              <div className={styles.playerToggle}>
                {(this.props.playing) ? (
                  <a href="#" onClick={ (e) => this.props.pause(e) } className={styles.postMetricsLink}>
                    <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-pause-icon.png')}`, width: playPauseIconHeight, height: playPauseIconHeight }}></div>
                  </a>
                ) : (
                  <a href="#" onClick={ (e) => this.props.play(e) } className={styles.postMetricsLink}>
                    <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-play-icon.png')}`, width: playPauseIconHeight, height: playPauseIconHeight }}></div>
                  </a>
                )}
              </div>
            )}

          </div>
        </a>
      </div>
    )
  }
}
