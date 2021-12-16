
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Row, Col } from 'reactstrap'

import styles from '../css/styles.css'


export default class Footer extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      currentUser: ""
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Footer componentDidMount()")
  }

  componentWillUnmount() {

  }

  render() {

    const props = this.props

    return (
      <div {...props} className={styles.footer}>

        Copyright © {(new Date().getFullYear())} App for teachers, Inc.

      </div>
    )
  }
}
