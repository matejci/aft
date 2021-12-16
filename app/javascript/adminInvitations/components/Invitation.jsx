
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Invitation extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
    this.handleEditClick = this.handleEditClick.bind(this)
  }

  componentDidMount() {
    console.log("class Invitation componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (invitation, updateInvitationsState) => (e) => {
    e.preventDefault()

    this.submitForm(invitation, updateInvitationsState)
  }

  handleEditClick = (invitation, updateInvitationsState) => (e) => {
    e.preventDefault()

    this.invitationEditModal.toggle()

    // this.submitForm(invitation, updateInvitationsState)
  }

  submitForm(invitation, updateInvitationsState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken
      }
    }

    // console.log("------- invitation._id.$oid -------: " + JSON.stringify(invitation))
    var postData = {
      params: {
        invitation_type: invitation._id.$oid
      }
    }
    

    // axios.post(`/invitation_types.json`, postData, postHeaders)
    axios.delete(`/invitations/${invitation._id.$oid}.json`, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // window.location = '/'
        // console.log("JSON.parse success => " + JSON.stringify(response.data))

        // update Invitations Type State on index.js
        updateInvitationsState(response.data.invitations)
        // console.log("response.data: " + response.data.invitation_types)
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
      })
  }

  submitConfirm = (adminSource, updateInvitationsState) => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => this.submitForm(adminSource, updateInvitationsState)
        },
        {
          label: 'No',
          // onClick: () => alert('Click No')
        }
      ]
    })
  }

  render() {
    const invitation = this.props.invitation

    // console.log("invitation animated.div: " + JSON.stringify(this.props.style))

    return (
      <tr style={this.props.style} className={styles.item}>
        <th scope="row">{invitation._id.$oid}</th>
        <td>{invitation.created_at}</td>
        <td>{invitation.claimed_date}</td>
        <td>{JSON.stringify(invitation.claimed)}</td>
        <td>{invitation.ip_address}</td>
        <td>{invitation.user_agent}</td>
        <td>{invitation.invite_code}</td>
        <td>{JSON.stringify(invitation.status)}</td>
        <td>{invitation.email_sent}</td>
        <td>{invitation.email_used}</td>
        <td>{invitation.invited_by}</td>
        <td>{invitation.invited_type}</td>
        <td>{JSON.stringify(invitation.attempts)}</td>
        <td>{invitation.number_of_attempts}</td>
        <td>{invitation.device_name}</td>
        <td>{invitation.device_type}</td>
        <td>{invitation.device_client_name}</td>
        <td>{invitation.device_client_full_version}</td>
        <td>{invitation.device_os}</td>
        <td>{invitation.device_os_full_version}</td>
        <td>{JSON.stringify(invitation.device_client_known)}</td>
      </tr>
    )
  }

  // render() {
  //   const invitation = this.props.invitation

  //   // console.log("invitation animated.div: " + JSON.stringify(this.props.style))

  //   return (
  //     <tr>
  //       <th scope="row">2</th>
  //       <td>Jacob</td>
  //       <td>Thornton</td>
  //       <td>@fat</td>
  //     </tr>
  //     <div style={this.props.style} className={styles.item}>
  //       <div className={styles.invitation}>
  //         {invitation._id.$oid} | 
  //         {invitation.email} 
  //         <span style={{fontSize:'12px'}}>
  //           {/*<a href="#" onClick={this.handleEditClick(invitation, this.props.updateInvitationsState).bind(this)} style={{color:'green'}}>Edit {invitation.name}</a>*/}
  //         </span>
  //       </div>

  //       {/*<InvitationsEditModal className="invitationEditModal" ref={instance => { this.invitationEditModal = instance }} invitation={ invitation } updateInvitationsState={ this.props.updateInvitationsState } />*/}
  //     </div>
  //   )
  // }
}
