
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'


const currentUserSession = (updateCurrentUserState) => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  var postHeaders = {
    headers: {
      'X-CSRF-Token': csrfToken,
      'HTTP-X-APP-TOKEN': appToken,
      'APP-ID': appId
    }
  }

  var postData = {
    current_user: currentUser
  }

  axios.post(`/current/user/session.json`, postData, postHeaders)
    .then(response => {
      // console.log("response: " + response)
      // console.log("JSON.parse success => " + JSON.stringify(response.data))
      // window.location = '/'
      currentUser = response.data
      updateCurrentUserState(currentUser)
    })
    .catch(error => {
      // console.error("error: " + error)
      // console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
      window.location = '/login'
      currentUser = false
      updateCurrentUserState(currentUser)
    })
}

export { currentUserSession }
