
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, ButtonGroup, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'
import MuiPhoneInput from 'material-ui-phone-number'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class PartOne extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      email: "",
      phone: "",
      username: "",
      password: "",
      birthdate: "",
      invite: "",
      tosAcceptance: false,
    }

    this.handleNumberInputChange = this.handleNumberInputChange.bind(this)
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleEmailPhoneToggle = this.handleEmailPhoneToggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    console.log("PartOne - componentDidMount() init")

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
          birthdate: this.state.birthdate,
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
          birthdate: this.state.birthdate,
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
      <div className={styles.usersFormBox}>
        <Row className="no-gutters">

          <Col sm="12" className="align-self-center">
            <div className={styles.containerBox}>

              <div className={styles.formBox}>

                <FormGroup className={styles.formGroup}>
                  <ButtonGroup className="btn-block" size="lg">
                    <Button className={this.props.emailPhoneToggle=="email" ? "active" : ""} onClick={ (e) => this.handleEmailPhoneToggle(e, "email", this.props.updateEmailPhoneToggleState) }>Email</Button>
                    <Button className={this.props.emailPhoneToggle=="phone" ? "active" : ""} onClick={ (e) => this.handleEmailPhoneToggle(e, "phone", this.props.updateEmailPhoneToggleState) }>Phone</Button>
                  </ButtonGroup>
                </FormGroup>

                <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUserState)}>

                  { this.props.emailPhoneToggle=="email" && (
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
                  )}

                  { this.props.emailPhoneToggle=="phone" && (
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
                        // inputProps={{
                        //   className: styles.formWrapperInput, // the CSS class name of the wrapper element
                        // }}
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
                        onChange={this.handleNumberInputChange}
                      />
                      <span className={styles.errorMessage}>{this.state.errors.phone}</span>
                    </FormGroup>
                  )}



                  <FormGroup className={styles.formGroup}>
                    <TextField
                      label="Password"
                      name="password"
                      id="password"
                      className={this.state.errors.password ? styles.formControl+" error" : styles.formControl}
                      type="password"
                      value={this.state.password}
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
                    <span className={styles.errorMessage}>{this.state.errors.password}</span>
                  </FormGroup>

                  <FormGroup className={styles.formGroup}>
                    <TextField
                      label="Username"
                      name="username"
                      id="username"
                      className={this.state.errors.username ? styles.formControl+" error" : styles.formControl}
                      type="text"
                      value={this.state.username}
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
                    <span className={styles.errorMessage}>{this.state.errors.username}</span>
                  </FormGroup>

                  <FormGroup className={styles.formGroup}>
                    <TextField
                      label="Birthdate"
                      name="birthdate"
                      id="birthdate"
                      className={this.state.errors.birthdate ? styles.formControl+" error" : styles.formControl}
                      type="date"
                      value={this.state.birthdate}
                      InputProps={{
                        disableUnderline: true,
                        className: styles.formWrapperInput, // the CSS class name of the wrapper element
                      }}
                      InputLabelProps={{
                        shrink: true,
                        classes: {
                          root: styles.formInputLabel, // Some CSS
                          focused: styles.formInputLabelFocused,
                          filled: styles.formInputLabelFilled,
                        }
                      }}
                      variant="filled"
                      onChange={this.handleInputChange} />
                    <span className={styles.errorMessage}>{this.state.errors.birthdate}</span>
                  </FormGroup>

                  <FormGroup className={styles.formGroup}>
                    <TextField
                      label="Invite"
                      name="invite"
                      id="invite"
                      className={this.state.errors.invite ? styles.formControl+" error" : styles.formControl}
                      type="text"
                      value={this.state.invite}
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
                    <span className={styles.errorMessage}>{this.state.errors.invite}</span>
                  </FormGroup>

                  <FormGroup className={styles.formGroup} check>
                    <Label className={styles.formCheckBoxLabel} check>
                      <Input type="checkbox" name="tosAcceptance" checked={this.state.tosAcceptance} onChange={this.handleCheckBox} />
                      By clicking Sign Up, you agree to our Terms, Data Policy, and Cookies Policies.
                    </Label>
                    <span className={styles.errorMessage}>{this.state.errors.tos_acceptance}</span>
                  </FormGroup>

                  <Button className={styles.nextButton} color="primary" size="lg" block>Sign Up</Button>

                </Form>

              </div>

            </div>
          </Col>

        </Row>
      </div>
    )
  }
}
