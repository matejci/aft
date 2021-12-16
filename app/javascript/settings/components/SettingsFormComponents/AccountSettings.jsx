
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, ButtonGroup, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'
import MuiPhoneInput from 'material-ui-phone-number'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class AccountSettings extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      user: this.props.user,
      email: this.props.user.email,
      firstName: this.props.user.first_name,
      lastName: this.props.user.last_name,
      phone: this.props.user.phone,
    }

    this.handleNumberInputChange = this.handleNumberInputChange.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleEmailPhoneToggle = this.handleEmailPhoneToggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.toggleBack = this.toggleBack.bind(this)
  }

  componentDidMount() {
    console.log("AccountSettings - componentDidMount() init")

    // this.props.goToStep(3)
  }

  componentWillUnmount() {

  }

  // static getDerivedStateFromProps(props, state) {
  //   if (props.order !== state.prevPropsOrder) {
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

    var postData = {
      user: {
        email: this.state.email,
        phone: this.state.phone,
        first_name: this.state.firstName,
        last_name: this.state.lastName,
      }
    }

    axios.patch(`/users/${this.props.user._id.$oid}.json`, postData, postHeaders)
      .then(response => {
        console.log("response: " + JSON.stringify(response))
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        // this.props.nextStep()

        // update Order Type State on index.js
        // updateUserState(response.data)

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


  toggleBack = (event) => {
    event.preventDefault()

    this.props.goToStep(1)
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
                    Account Settings
                  </h1>
                </Col>
              </Row>

              <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUserState)}>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="Email"
                    name="email"
                    id="email"
                    className={this.state.errors.email ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.email}
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
                  <span className={styles.errorMessage}>{this.state.errors.email}</span>
                </FormGroup>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="First Name"
                    name="firstName"
                    name="firstName"
                    id="email"
                    className={this.state.errors.first_name ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.firstName}
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
                  <span className={styles.errorMessage}>{this.state.errors.first_name}</span>
                </FormGroup>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="Last Name"
                    name="lastName"
                    name="lastName"
                    id="email"
                    className={this.state.errors.last_name ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.lastName}
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
                  <span className={styles.errorMessage}>{this.state.errors.last_name}</span>
                </FormGroup>

                <FormGroup className={styles.formPhoneGroup}>
                  <MuiPhoneInput
                    native={true}
                    defaultCountry='us'
                    label="Phone"
                    name="phone"
                    id="phone"
                    className={this.state.errors.phone ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.phone}
                    disableAreaCodes={true}
                    inputClass={styles.formWrapperInput}
                    inputProps={{
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
                    onChange={this.handleNumberInputChange}
                  />
                  <span className={styles.errorMessage}>{this.state.errors.phone}</span>
                </FormGroup>


                <Button className={styles.nextButton} color="primary" size="lg">Update</Button>

              </Form>

              <br />
              <br />
              <a href="#" onClick={ (e) => this.toggleBack(e) } className={styles.backButton}><img src="/assets/back-icon.png" /></a>

            </div>

          </div>
        </Col>

      </Row>
    )
  }
}
