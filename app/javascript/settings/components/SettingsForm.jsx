
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, ListGroup, ListGroupItem, Dropdown, DropdownItem, DropdownToggle, DropdownMenu } from 'reactstrap'
import { currentUserSession } from '../../currentUser/components/CurrentUser'

import { withStyles } from '@material-ui/core/styles'
import Dialog from '@material-ui/core/Dialog'
import MuiDialogTitle from '@material-ui/core/DialogTitle'
import MuiDialogContent from '@material-ui/core/DialogContent'
import MuiDialogActions from '@material-ui/core/DialogActions'

import StepWizard from 'react-step-wizard'
import Settings from './SettingsFormComponents/Settings'
import ProfileSettings from './SettingsFormComponents/ProfileSettings'
import AccountSettings from './SettingsFormComponents/AccountSettings'
import Password from './SettingsFormComponents/Password'
import PartTwo from './SettingsFormComponents/PartTwo'

import '!style-loader!css-loader!animate.css'
import cx from 'classnames'
import styles from '../css/styles.css'

export default class SettingsForm extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      currentUser: currentUser,
      user: {},
      first_name: "",
      last_name: "",
      email: "",
      password: "",
      username: "",
      emailPhoneToggle: "email",
      dropdownOpen: false,
    }

    this.toggle = this.toggle.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleErrors = this.handleErrors.bind(this)
    this.updateUserState = this.updateUserState.bind(this)
    this.updateEmailPhoneToggleState = this.updateEmailPhoneToggleState.bind(this)
    this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })
  }

  componentDidMount() {
    console.log("class SettingsForm componentDidMount")

    var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getUser()
  }

  componentWillUnmount() {

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

  getUser() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }
    // var postData = {
    //   user: {
    //     first_name: this.state.first_name,
    //     last_name: this.state.last_name,
    //     email: this.state.email,
    //     password: this.state.password,
    //     username: this.state.username,
    //   }
    // }


    axios.post(`/get/current/user.json`, {}, postHeaders)
      .then(response => {
        console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        // window.location = '/'
        console.log("JSON.parse success => " + JSON.stringify(response.data))
        this.setState({ user: response.data })
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.handleErrors()
        // this.setState({ fireRedirect: true })
      })
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


  updateUserState = (data) => {
    this.setState({ user: data })
    console.log("updateUserState(data) completed")
  }

  updateEmailPhoneToggleState = (data) => {
    this.setState({ emailPhoneToggle: data })
    console.log("updateEmailPhoneToggleState(data) completed")
  }

  toggle() {
    this.setState({
      dropdownOpen: !this.state.dropdownOpen
    })
  }


  render() {

    return (
      <div className={styles.usersFormWrap}>

        <div className={styles.accountBox}>
          <div className="nav">
            <Dropdown nav inNavbar={true} direction={'down'} className={styles.buttonDropdown} isOpen={this.state.dropdownOpen} toggle={this.toggle}>
              <DropdownToggle nav caret>
                {this.state.currentUser.email}
              </DropdownToggle>
              <DropdownMenu className={styles.dropdownMenu}>
                <DropdownItem header>Creator HQ</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Dashboard</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Upload</DropdownItem>
                <DropdownItem header>Account</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Payments</DropdownItem>
                <DropdownItem href="/settings" className={styles.dropdownItem}>Settings</DropdownItem>
                <DropdownItem divider />
                <DropdownItem href="/signout" className={styles.dropdownItemLast}>
                  Signout
                </DropdownItem>
              </DropdownMenu>
            </Dropdown>
          </div>
        </div>

        <StepWizard
          className={"h-100"}
          // nav={<Nav />}
          transitions={{
            enterRight: 'animated fadeIn',
            enterLeft : 'animated fadeIn',
            exitRight : 'animated fadeOut',
            exitLeft  : 'animated fadeOut',
          }}
          isLazyMount={true}
          isHashEnabled={false}>

          <Settings currentUser={this.state.currentUser} user={this.state.user} updateUserState={this.updateUserState} />

          <ProfileSettings user={this.state.user} updateUserState={this.updateUserState} />

          <AccountSettings user={this.state.user} updateUserState={this.updateUserState} link={this.state.link} emailPhoneToggle={this.state.emailPhoneToggle} updateEmailPhoneToggleState={this.updateEmailPhoneToggleState} />

          <Password user={this.state.user} updateUserState={this.updateUserState} />



          {/* <PartTwo user={this.state.user} updateUserState={this.updateUserState} /> */ }

        </StepWizard>

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
