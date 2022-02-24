
import React, { useState, useEffect, useCallback } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

var selectedPostExternal = null
// var startTime = Date.now() /* persist start time to ignore short buffers */
var startStatus = false
var eventStatus = ''

const updateEventSelectedPost = (selectedPost) => {
	// console.log('updateEventSelectedPost')

	selectedPostExternal = selectedPost
  startStatus = false
}

const trackEvent = (event) => {
  // console.log('trackEvent')

  var filteredEvent = eventService(event)
  if (filteredEvent) {
    // console.log(`filteredEvent: ${JSON.stringify(filteredEvent)}`)
    sendEvent(filteredEvent)
  }

}

const eventService = (event) => {
  switch(event) {
    case 'start':
      startStatus = true
      eventStatus = event
      return 'start'
    case 'play':
      if (eventStatus != 'start' && eventStatus == 'pause') {
        eventStatus = 'resume'
        return 'resume'
      }
      return null
    case 'pause':
      eventStatus = event
      return 'pause'
    case 'buffering_start':
      eventStatus = event
      return 'buffering_start'
    case 'buffering_end':
      if (eventStatus == 'buffering_start') {
        eventStatus = 'buffering_end'
        return 'buffering_end'
      }
      return null
    default:
      return null
  }
}

const sendEvent = (action) => {
  const selectedPost = selectedPostExternal
  const link = selectedPost.link

  const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
  var postHeaders = {
    headers: {
      'X-CSRF-Token': csrfToken,
      'HTTP-X-APP-TOKEN': appToken,
      'APP-ID': appId
    }
  }

  var postData = {
    link: `${link}`
  }

  // post item
  axios.post(`/p/${link}/v/${action}.json`, postData, postHeaders)
    .then(response => {
      const data = response.data
    })
    .catch(error => {
      console.error("sendEvent error: " + error)
    })
}

export { updateEventSelectedPost, trackEvent }
