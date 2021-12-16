
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Col } from 'reactstrap'

import styles from './css/styles.css'

import SidebarIndex from './components/SidebarIndex'

export default class Sidebar extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      currentUser: ""
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Sidebar componentDidMount()")
  }

  componentWillUnmount() {

  }

  render() {

    // parse currentUser from otherProps to avoid Col dom prop issue
    var {currentUser, updatePage, ...otherProps} = this.props

    console.log(" ")
    console.log("currentUser:")
    console.log( JSON.stringify(currentUser))
    console.log(" ")

    return (
      <Col {...otherProps} className={styles.sidebar}>

        <SidebarIndex active={this.props.active} currentUser={currentUser} updatePage={updatePage} />

      </Col>
    )
  }
}