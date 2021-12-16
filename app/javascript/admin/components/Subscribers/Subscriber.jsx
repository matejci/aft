
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Subscriber extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
    this.handleEditClick = this.handleEditClick.bind(this)
  }

  componentDidMount() {
    console.log("class Subscriber componentDidMount")
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

    // console.log("------- subscriber._id -------: " + JSON.stringify(subscriber))
    var postData = {
      params: {
        subscriber_type: subscriber.id
      }
    }
    

    // axios.post(`/subscriber_types.json`, postData, postHeaders)
    axios.delete(`/subscribers/${subscriber.id}.json`, postHeaders)
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
    const subscriber = this.props.subscriber

    // console.log("subscriber animated.div: " + JSON.stringify(this.props.style))

    return (
      <tr style={this.props.style} className={styles.item}>
        <th scope="row">{subscriber.id}</th>
        <td>{subscriber.created_at}</td>
        <td>{subscriber.firstName}</td>
        <td>{subscriber.lastName}</td>
        <td>{subscriber.email}</td>
        <td>{subscriber.phone}</td>
        <td>{subscriber.mobile_device}</td>
        <td>{subscriber.link}</td>
        <td>{subscriber.queue}</td>
        <td>{subscriber.position}</td>
        <td>{subscriber.ip_address}</td>
        <td>{subscriber.user_agent}</td>
        <td>{JSON.stringify(subscriber.email_delivery_status)}</td>
        <td>{subscriber.email_delivery_date}</td>
        <td>{subscriber.referred_by}</td>
      </tr>
    )
  }

  // render() {
  //   const subscriber = this.props.subscriber

  //   // console.log("subscriber animated.div: " + JSON.stringify(this.props.style))

  //   return (
  //     <tr>
  //       <th scope="row">2</th>
  //       <td>Jacob</td>
  //       <td>Thornton</td>
  //       <td>@fat</td>
  //     </tr>
  //     <div style={this.props.style} className={styles.item}>
  //       <div className={styles.subscriber}>
  //         {subscriber.id} | 
  //         {subscriber.email} 
  //         <span style={{fontSize:'12px'}}>
  //           {/*<a href="#" onClick={this.handleEditClick(subscriber, this.props.updateSubscribersState).bind(this)} style={{color:'green'}}>Edit {subscriber.name}</a>*/}
  //         </span>
  //       </div>

  //       {/*<SubscribersEditModal className="subscriberEditModal" ref={instance => { this.subscriberEditModal = instance }} subscriber={ subscriber } updateSubscribersState={ this.props.updateSubscribersState } />*/}
  //     </div>
  //   )
  // }
}
