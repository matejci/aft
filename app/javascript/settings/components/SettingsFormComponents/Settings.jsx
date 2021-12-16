
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, ButtonGroup, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'
import MuiPhoneInput from 'material-ui-phone-number'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class Settings extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      user: "",
      email: "",
      phone: "",
      username: "",
      password: "",
      invite: "",
      tosAcceptance: false,
    }

    this.handleNumberInputChange = this.handleNumberInputChange.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleEmailPhoneToggle = this.handleEmailPhoneToggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.toggleSection = this.toggleSection.bind(this)
  }

  componentDidMount() {
    console.log("Settings - componentDidMount() init")

    // this.props.goToStep(3)
  }

  componentWillUnmount() {

  }

  // static getDerivedStateFromProps(props, state) {
  //   if (props.order !== state.prevPropsUser) {
  //     return {
  //       prevPropsOrder: props.order,
  //       order: props.order,
  //       email: props.order.email
  //     }
  //   }
  //   return null
  // }


  handleNumberInputChange(value) {
    this.setState({
      phone: value
    })

    console.log("~~~~ handleNumberInputChange: " + value)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })

    // console.log("~~~~ handleInputChange: " + name + " => " + value)
  }

  handleCheckBox(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: target.checked
    })
    // console.log("handleCheckBox: " + name + ' => ' + target.checked)
  }

  handleEmailPhoneToggle = (e, toggle, updateEmailPhoneToggleState) => {
    e.preventDefault()

    updateEmailPhoneToggleState(toggle)
  }

  handleSubmit = (e, updateUserState) => {
    e.preventDefault()

    this.submitForm(updateUserState)
  }


  submitForm(updateUserState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    // const appToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    var postData = {}

    if (this.props.emailPhoneToggle=="email") {
      postData = {
        user: {
          email: this.state.email,
          username: this.state.username,
          password: this.state.password,
          invite: this.state.invite,
          tos_acceptance: this.state.tosAcceptance,
        }
      }
    } else {
      postData = {
        user: {
          phone: this.state.phone,
          username: this.state.username,
          password: this.state.password,
          invite: this.state.invite,
          tos_acceptance: this.state.tosAcceptance,
        }
      }
    }


    axios.post(`/users.json`, postData, postHeaders)
      .then(response => {
        console.log("response: " + JSON.stringify(response))
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        this.props.nextStep()

        // update Order Type State on index.js
        updateUserState(response.data)

        console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.setState({ fireRedirect: true })
      })
  }


  toggleSection = (event, num) => {
    event.preventDefault()

    this.props.goToStep(num)
  }


  render() {

    const phoneInput = () => (
      <TextField
        label="Phone 123"
        name="phone"
        id="phone"
        className={this.state.errors.phone ? styles.formControl+" error" : styles.formControl}
        type="text"
        value={this.state.phone}
        InputProps={{
          disableUnderline: true,
          className: styles.formWrapperInput, // the CSS class name of the wrapper element
        }}
        InputLabelProps={{
          classes: {
            root: styles.formInputLabel, // Some CSS
            focused: styles.formInputLabelFocused,
            filled: styles.formInputLabelFilled,
          }
        }}
        variant="filled"
        onChange={this.handleInputChange} />
    )

    return (
      <Row className="no-gutters">

        <Col sm="12" className="align-self-center">
          <div className={styles.containerBox}>

            <div className={styles.formBox}>

              <Row className={styles.header}>
                <Col md="12">
                  <h1>
                    Settings
                  </h1>
                </Col>
              </Row>

              <Row>
                <Col md="4">

                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink} onClick={ (e) => this.toggleSection(e, 2) }>
                      <h2>Profile Settings</h2>
                      <p>Change your profile settings here</p>
                    </a>
                  </div>

                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink} onClick={ (e) => this.toggleSection(e, 3) }>
                      <h2>Account Settings</h2>
                      <p>Change your account settings here</p>
                    </a>
                  </div>

                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink} onClick={ (e) => this.toggleSection(e, 4) }>
                      <h2>Change Password</h2>
                      <p>Change your account password</p>
                    </a>
                  </div>

                  {/*
                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink}>
                      <h2>Security Settings</h2>
                      <p>Settings and recommendations to help you keep your account secure</p>
                    </a>
                  </div>
                  */}

                </Col>

                <Col md="4">

                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink}>
                      <h2>Payment Settings</h2>
                      <p>Your payment info and transactions</p>
                    </a>
                  </div>

                  <div className={styles.settingsSectionLinkWrap}>
                    <a href="#"className={styles.settingsSectionLink}>
                      <h2>Help</h2>
                      <p>Answers to common questions, expert advice, and a way to provide feedback</p>
                    </a>
                  </div>

                </Col>
              </Row>

            </div>

          </div>
        </Col>

      </Row>
    )
  }
}
