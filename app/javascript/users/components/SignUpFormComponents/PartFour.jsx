
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import MuiPhoneInput from 'material-ui-phone-number'

import TextField from '@material-ui/core/TextField'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class PartThree extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      phone: "",
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleNumberInputChange = this.handleNumberInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    console.log("PartThree - componentDidMount() init")
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



  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })

    console.log("~~~~ handleInputChange: " + name + " => " + value)
  }

  handleNumberInputChange(value) {
    this.setState({
      phone: value
    })

    console.log("~~~~ handleNumberInputChange: " + value)
  }

  handleCheckBox(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: target.checked
    })
    console.log("handleCheckBox: " + name + ' => ' + target.checked)
  }

  handleSubmit = (e, updateUserState) => {
    e.preventDefault()

    this.submitForm(updateUserState)
  }


  submitForm(updateUserState) {
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
        phone: this.state.phone,
      }
    }


    axios.patch(`/users/${this.props.user._id.$oid}.json`, postData, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        // this.props.nextStep()

        // update Order Type State on index.js
        updateUserState(response.data)

        this.props.toggleConfetti()
        this.props.toggleModal()

        // console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        // console.error("error: " + error)
        // console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
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

              <div className="formBox">

                <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUserState)}>

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
                  </FormGroup>

                  <Button className={styles.nextButton} color="primary" size="lg" block>Sign up!</Button>

                </Form>

              </div>

            </div>
          </Col>

        </Row>
      </div>
    )
  }
}
