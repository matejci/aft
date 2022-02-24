
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import ProgressBar from "@ramonak/react-progress-bar"

import cx from 'classnames'
import styles from '../css/styles.css'


export default class PlayedProgressBar extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      played: 0,
    }

    this.updateProgress = this.updateProgress.bind(this)
  }

  componentDidMount() {
    console.log("class VideoProgressBar componentDidMount")
  }

  componentWillUnmount() {

  }

  updateProgress = (played) => {
    this.setState({ played })
  }

  render() {
    const progress = this.state.played*100

    return (
      <React.Fragment>
        <ProgressBar
          className={styles.progressBar}
          completed={progress}
          isLabelVisible={false}
          transitionDuration={'0.1s'}
          height={'5px'}
          bgColor={'rgba(118, 70, 254, 0.2)'}
          baseBgColor={'rgba(255,255,255,0.05)'}
          transitionTimingFunction={'ease-in'}
        />
      </React.Fragment>
    )
  }

}
