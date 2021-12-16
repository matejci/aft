
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Badge } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Username extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
    this.handleEditClick = this.handleEditClick.bind(this)
  }

  componentDidMount() {
    console.log("class Username componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (subscriber, updateSubscribersState) => (e) => {
    e.preventDefault()

    this.submitForm(subscriber, updateSubscribersState)
  }

  handleEditClick = (subscriber, updateSubscribersState) => (e) => {
    e.preventDefault()

    this.subscriberEditModal.toggle()

    // this.submitForm(subscriber, updateSubscribersState)
  }

  submitForm(subscriber, updateSubscribersState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    // console.log("------- subscriber._id.$oid -------: " + JSON.stringify(subscriber))
    var postData = {
      params: {
        subscriber_type: subscriber._id.$oid
      }
    }
    

    // axios.post(`/subscriber_types.json`, postData, postHeaders)
    axios.delete(`/subscribers/${subscriber._id.$oid}.json`, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // window.location = '/'
        // console.log("JSON.parse success => " + JSON.stringify(response.data))

        // update Subscribers Type State on index.js
        updateSubscribersState(response.data.subscribers)
        // console.log("response.data: " + response.data.subscriber_types)
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
      })
  }

  submitConfirm = (adminSource, updateSubscribersState) => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => this.submitForm(adminSource, updateSubscribersState)
        },
        {
          label: 'No',
          // onClick: () => alert('Click No')
        }
      ]
    })
  }

  render() {
    const username = this.props.username

    // console.log("username animated.div: " + JSON.stringify(this.props.style))

    return (
      <tr style={this.props.style} className={styles.item}>
        <th scope="row">{username.id}</th>
        <td>{username.created_at}</td>
        <td>{username.name}</td>
        <td>{JSON.stringify(username.status)}</td>
        <td><Badge href="#" color="dark">{username.type}</Badge></td>
      </tr>
    )
  }

}
