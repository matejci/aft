
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import AdminSessionsIndex from './components/AdminSessionsIndex'

class Admin extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      errors: {} 
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Admin Sessions componentDidMount()")
  }

  componentWillUnmount() {

  }

  // updateCurrentUserState(currentUserState) {
  //   this.setState({
  //     currentUser: currentUserState
  //   })
  // }


  render() {
    return (
      <React.Fragment>

        <AdminSessionsIndex />

      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Admin />,
  document.body.appendChild(document.getElementById('content'))
)
