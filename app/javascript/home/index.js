
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import HomeIndex from './components/HomeIndex'

class Home extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      errors: {} 
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Home componentDidMount()")
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

        <HomeIndex />

      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Home />,
  document.body.appendChild(document.getElementById('content'))
)
