
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Session extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
    this.handleEditClick = this.handleEditClick.bind(this)
  }

  componentDidMount() {
    console.log("class Session componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (session, updateSessionsState) => (e) => {
    e.preventDefault()

    this.submitForm(session, updateSessionsState)
  }

  handleEditClick = (session, updateSessionsState) => (e) => {
    e.preventDefault()

    this.sessionEditModal.toggle()

    // this.submitForm(session, updateSessionsState)
  }

  submitForm(session, updateSessionsState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    // console.log("------- session._id.$oid -------: " + JSON.stringify(session))
    var postData = {
      params: {
        session_type: session._id.$oid
      }
    }
    

    // axios.post(`/session_types.json`, postData, postHeaders)
    axios.delete(`/sessions/${session._id.$oid}.json`, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // window.location = '/'
        // console.log("JSON.parse success => " + JSON.stringify(response.data))

        // update Sessions Type State on index.js
        updateSessionsState(response.data.sessions)
        // console.log("response.data: " + response.data.session_types)
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
      })
  }

  submitConfirm = (adminSource, updateSessionsState) => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => this.submitForm(adminSource, updateSessionsState)
        },
        {
          label: 'No',
          // onClick: () => alert('Click No')
        }
      ]
    })
  }

  render() {
    const session = this.props.session

    // console.log("session animated.div: " + JSON.stringify(this.props.style))

    return (
      <tr style={this.props.style} className={styles.item}>
        <th scope="row">{session._id.$oid}</th>
        <td>{session.created_at}</td>
        <td>{session.last_login}</td>
        <td>{session.last_activity}</td>
        <td>{session.ip_address}</td>
        <td>{session.user}</td>
        <td>{session.access_token}</td>
        <td>{session.token}</td>
        <td>{session.user_agent}</td>
        <td>{session.exp_date}</td>
        <td>{JSON.stringify(session.status)}</td>
        <td>{JSON.stringify(session.live)}</td>
        <td>{session.device_name}</td>
        <td>{session.device_type}</td>
        <td>{session.device_client_name}</td>
        <td>{session.device_client_full_version}</td>
        <td>{session.device_os}</td>
        <td>{session.device_os_full_version}</td>
        <td>{JSON.stringify(session.device_client_known)}</td>
        <td>{session.app_id} | {session.app}</td>
      </tr>
    )
  }

  // render() {
  //   const session = this.props.session

  //   // console.log("session animated.div: " + JSON.stringify(this.props.style))

  //   return (
  //     <tr>
  //       <th scope="row">2</th>
  //       <td>Jacob</td>
  //       <td>Thornton</td>
  //       <td>@fat</td>
  //     </tr>
  //     <div style={this.props.style} className={styles.item}>
  //       <div className={styles.session}>
  //         {session._id.$oid} | 
  //         {session.email} 
  //         <span style={{fontSize:'12px'}}>
  //           {/*<a href="#" onClick={this.handleEditClick(session, this.props.updateSessionsState).bind(this)} style={{color:'green'}}>Edit {session.name}</a>*/}
  //         </span>
  //       </div>

  //       {/*<SessionsEditModal className="sessionEditModal" ref={instance => { this.sessionEditModal = instance }} session={ session } updateSessionsState={ this.props.updateSessionsState } />*/}
  //     </div>
  //   )
  // }
}
