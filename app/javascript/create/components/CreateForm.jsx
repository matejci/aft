
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText } from 'reactstrap'
import copy from 'copy-to-clipboard'

import { withStyles } from '@material-ui/core/styles'
import Dialog from '@material-ui/core/Dialog'
import MuiDialogTitle from '@material-ui/core/DialogTitle'
import MuiDialogContent from '@material-ui/core/DialogContent'
import MuiDialogActions from '@material-ui/core/DialogActions'

import StepWizard from 'react-step-wizard'
import PartOne from './CreateFormComponents/PartOne'
import PartTwo from './CreateFormComponents/PartTwo'
import PartTwoPhone from './CreateFormComponents/PartTwoPhone'
import PartTwoEmail from './CreateFormComponents/PartTwoEmail'
import PartThree from './CreateFormComponents/PartThree'

import cx from 'classnames'

import styles from '../css/styles.css'

export default class CreateForm extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      post: {},
      first_name: "",
      last_name: "",
      email: "",
      password: "",
      username: "",
      emailPhoneToggle: "email",
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleErrors = this.handleErrors.bind(this)
    this.updatePostState = this.updatePostState.bind(this)
    this.updateEmailPhoneToggleState = this.updateEmailPhoneToggleState.bind(this)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })

  }

  handleSubmit(event) {
    event.preventDefault()

    this.createUser()
  }


  createUser() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }
    var postData = {
      user: {
        first_name: this.state.first_name,
        last_name: this.state.last_name,
        email: this.state.email,
        password: this.state.password,
        username: this.state.username,
      }
    }


    axios.post(`/users.json`, postData, postHeaders)
      .then(response => {
        console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        window.location = '/'
        console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.handleErrors()
        // this.setState({ fireRedirect: true })
      })
  }

  handleErrors(clear) {
    if (clear) {
      var errors = document.getElementsByClassName(error)
      this.setState(this.initialState)
    } else {
      let errors = this.state.errors
      let thisState = this
      Object.keys(errors).forEach(function(key, value) {
        console.log("key: " + key + " | " + errors[key])
        if (errors[key]) {
          thisState.setState({ [key+"_error"]: errors[key] })
        } else {
          thisState.setState({ [key+"_error"]: {} })
        }
      })
    }
  }


  componentDidMount() {
    console.log("CreateForm - componentDidMount() init")
  }

  componentWillUnmount() {

  }

  updatePostState = (data) => {
    this.setState({ post: data })
    console.log("updatePostState(data) completed")
  }

  updateEmailPhoneToggleState = (data) => {
    this.setState({ emailPhoneToggle: data })
    console.log("updateEmailPhoneToggleState(data) completed")
  }


  render() {

    return (
      <div className={styles.usersFormWrap}>

        <StepWizard
          className={"h-100"}
          // nav={<Nav />}
          isLazyMount={true}
          isHashEnabled={false}>

          <PartOne post={this.state.post} updatePostState={this.updatePostState} link={this.state.link} emailPhoneToggle={this.state.emailPhoneToggle} updateEmailPhoneToggleState={this.updateEmailPhoneToggleState} />

          <PartTwo post={this.state.post} updatePostState={this.updatePostState} />

          <PartThree post={this.state.post} updatePostState={this.updatePostState} toggleModal={this.toggleModal} toggleConfetti={this.props.toggleConfetti} />

        </StepWizard>

      </div>
    )
  }

}
