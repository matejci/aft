
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import EmbedIndex from './components/EmbedIndex'

class Embed extends React.Component {

	constructor(props) {
    super(props)
    this.state = {
      errors: {} 
    }

    // this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Embed componentDidMount()")
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

        <EmbedIndex />

      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Embed />,
  document.body.appendChild(document.getElementById('content'))
)
