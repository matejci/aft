
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


export default class EmbedBackground extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      background: "",
    }

    this.updateBackground = this.updateBackground.bind(this)
  }

  /*
  static getDerivedStateFromProps(props, state) {
    if (props.background !== state.background) {
      return {
        background: props.background
      }
    }
    return null
  }*/

  componentDidMount() {
    // console.log("class EmbedBackground componentDidMount")
  }

  componentWillUnmount() {

  }

  updateBackground = (background) => {
    this.setState({ background })
  }

  render() {
    return (
      <React.Fragment>
        <div className={styles.background} style={{ backgroundImage: `url('${this.state.background}')` }} >
          <div className={styles.darkBackground}></div>
        </div>
      </React.Fragment>
    )
  }

}