
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import AdminInvitationsIndex from './components/AdminInvitationsIndex'

class Admin extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      errors: {} 
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Admin Invitations componentDidMount()")
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

        <AdminInvitationsIndex />

      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Admin />,
  document.body.appendChild(document.getElementById('content'))
)
