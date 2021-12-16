
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import ProfileIndex from './components/ProfileIndex'

class Profile extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      errors: {} 
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Profile componentDidMount()")
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

        <ProfileIndex />

      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Profile />,
  document.body.appendChild(document.getElementById('content'))
)
