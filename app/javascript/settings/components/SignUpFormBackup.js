
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
import PartOne from './SignUpFormComponents/PartOne'
import PartTwo from './SignUpFormComponents/PartTwo'
import PartThree from './SignUpFormComponents/PartThree'

import cx from 'classnames'

import styles from '../css/styles.css'

export default class SignUpForm extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      first_name: "",
      last_name: "",
      email: "",
      password: "",
      username: ""
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleErrors = this.handleErrors.bind(this)
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

  }

  componentWillUnmount() {

  }



  render() {

    return (
      <div
        className={styles.SignUpBox}>
          <h2>Sign Up</h2>
          <p>Create an account</p>

          <StepWizard
                className={"h-100"}
                // nav={<Nav />}
                // isLazyMount={true}
                isHashEnabled={false}>

                <PartOne subscriber={this.state.subscriber} updateSubscriberState={this.updateSubscriberState} link={this.state.link} />

                <PartTwo subscriber={this.state.subscriber} updateSubscriberState={this.updateSubscriberState} />

                <PartThree subscriber={this.state.subscriber} updateSubscriberState={this.updateSubscriberState} toggleModal={this.toggleModal} toggleConfetti={this.props.toggleConfetti} />

              </StepWizard>

          <Form className={styles.userForm} onSubmit={this.handleSubmit}>

            <Row>
              <Col md="6">
                <FormGroup className={styles.formGroup}>
                  <Label>First Name</Label>
                  <Input
                    name="first_name"
                    className={this.state.errors.first_name ? styles.error : ""}
                    type="text"
                    value={this.state.first_name}
                    placeholder="First name"
                    onChange={this.handleInputChange} />
                  <span className={this.state.errors.first_name ? styles.error_message : ""}>{this.state.errors.first_name}</span>
                </FormGroup>
              </Col>
              <Col md="6">
                <FormGroup className={styles.formGroup}>
                  <Label>Last Name</Label>
                  <Input
                    name="last_name"
                    className={this.state.errors.last_name ? styles.error : ""}
                    type="text"
                    value={this.state.last_name}
                    placeholder="Last name"
                    onChange={this.handleInputChange} />
                  <span className={this.state.errors.last_name ? styles.error_message : ""}>{this.state.errors.last_name}</span>
                </FormGroup>
              </Col>
            </Row>

            <FormGroup className={styles.formGroup}>
              <Label>Email</Label>
              <Input
                name="email"
                className={this.state.errors.email ? styles.error : ""}
                type="text"
                value={this.state.email}
                placeholder="Email address"
                onChange={this.handleInputChange} />
              <span className={this.state.errors.email ? styles.error_message : ""}>{this.state.errors.email}</span>
            </FormGroup>

            <FormGroup className={styles.formGroup}>
              <Label>Password</Label>
              <Input
                name="password"
                className={this.state.errors.password ? styles.error : ""}
                type="password"
                value={this.state.password}
                placeholder="Password"
                onChange={this.handleInputChange} />
              <span className={this.state.errors.password ? styles.error_message : ""}>{this.state.errors.password}</span>
            </FormGroup>

            <FormGroup className={styles.formGroup}>
              <Label>Username</Label>
              <Input
                name="username"
                className={this.state.errors.username ? styles.error : ""}
                type="text"
                value={this.state.username}
                placeholder="Username"
                onChange={this.handleInputChange} />
              <span className={this.state.errors.username ? styles.error_message : ""}>{this.state.errors.username}</span>
            </FormGroup>

            <Button type="submit">Sign up</Button>

          </Form>

      </div>
    )
  }




  // render() {

  //   return (
  //     <div
  //       className={styles.SignUpBox} >
  //         <h2>Sign Up</h2>
  //         <p>Create an account</p>

  //         <Form className={styles.userForm} onSubmit={this.handleSubmit}>

  //           <Row>
  //             <Col md="6">
  //               <FormGroup className={styles.formGroup}>
  //                 <Label>First Name</Label>
  //                 <Input
  //                   name="first_name"
  //                   className={this.state.errors.first_name ? styles.error : ""}
  //                   type="text"
  //                   value={this.state.first_name}
  //                   placeholder="First name"
  //                   onChange={this.handleInputChange} />
  //                 <span className={this.state.errors.first_name ? styles.error_message : ""}>{this.state.errors.first_name}</span>
  //               </FormGroup>
  //             </Col>
  //             <Col md="6">
  //               <FormGroup className={styles.formGroup}>
  //                 <Label>Last Name</Label>
  //                 <Input
  //                   name="last_name"
  //                   className={this.state.errors.last_name ? styles.error : ""}
  //                   type="text"
  //                   value={this.state.last_name}
  //                   placeholder="Last name"
  //                   onChange={this.handleInputChange} />
  //                 <span className={this.state.errors.last_name ? styles.error_message : ""}>{this.state.errors.last_name}</span>
  //               </FormGroup>
  //             </Col>
  //           </Row>

  //           <FormGroup className={styles.formGroup}>
  //             <Label>Email</Label>
  //             <Input
  //               name="email"
  //               className={this.state.errors.email ? styles.error : ""}
  //               type="text"
  //               value={this.state.email}
  //               placeholder="Email address"
  //               onChange={this.handleInputChange} />
  //             <span className={this.state.errors.email ? styles.error_message : ""}>{this.state.errors.email}</span>
  //           </FormGroup>

  //           <FormGroup className={styles.formGroup}>
  //             <Label>Password</Label>
  //             <Input
  //               name="password"
  //               className={this.state.errors.password ? styles.error : ""}
  //               type="password"
  //               value={this.state.password}
  //               placeholder="Password"
  //               onChange={this.handleInputChange} />
  //             <span className={this.state.errors.password ? styles.error_message : ""}>{this.state.errors.password}</span>
  //           </FormGroup>

  //           <FormGroup className={styles.formGroup}>
  //             <Label>Username</Label>
  //             <Input
  //               name="username"
  //               className={this.state.errors.username ? styles.error : ""}
  //               type="text"
  //               value={this.state.username}
  //               placeholder="Username"
  //               onChange={this.handleInputChange} />
  //             <span className={this.state.errors.username ? styles.error_message : ""}>{this.state.errors.username}</span>
  //           </FormGroup>

  //           <Button type="submit">Sign up</Button>

  //         </Form>

  //     </div>
  //   )
  // }
}
