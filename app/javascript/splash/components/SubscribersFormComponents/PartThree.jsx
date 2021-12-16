
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
      age: "",
      mobileDevice: "",
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

  handleSubmit = (e, updateSubscriberState) => {
    e.preventDefault()

    this.submitForm(updateSubscriberState)
  }


  submitForm(updateSubscriberState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }
    var postData = {
      subscriber: {
        phone: this.state.phone,
        age: this.state.age,
        mobile_device: this.state.mobileDevice,
        triggerEmail: true,
      }
    }


    axios.patch(`/subscribers/${this.props.subscriber.id}.json`, postData, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        // this.props.nextStep()

        // update Order Type State on index.js
        updateSubscriberState(response.data)

        this.props.toggleConfetti()
        this.props.toggleModal()

        // console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        this.props.errorShake()
        // console.error("error: " + error)
        // console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.setState({ fireRedirect: true })
      })
  }


  render() {

    const ageOptions = [
      { name: "14-18", value: "14-18" },
      { name: "19-24", value: "19-24" },
      { name: "25-29", value: "25-29" },
      { name: "30-34", value: "30-34" },
      { name: "35-39", value: "35-39" },
      { name: "40+", value: "40+" }
    ]

    const deviceOptions = [
      { name: "iPhone", value: "iPhone" },
      { name: "Android", value: "Android" },
    ]

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
      <Row>

        <Col sm="12" className="align-self-center">
          <div className={styles.containerBox}>

            <div className="formBox">

              <Form className="subscribersForm" onSubmit={ (e) => this.handleSubmit(e, this.props.updateSubscriberState)}>

                <FormGroup className={styles.formPhoneGroup}>
                  <MuiPhoneInput
                    native={true}
                    defaultCountry='us'
                    label="Phone (optional)"
                    name="phone"
                    id="phone"
                    className={this.state.errors.phone ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.phone}
                    disableAreaCodes={true}
                    inputClass={styles.formWrapperInput}
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
                </FormGroup>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="How old are you?"
                    select
                    name="age"
                    id="age"
                    className={this.state.errors.age ? styles.formControl+" error" : styles.formControl}
                    value={this.state.age}
                    SelectProps={{
                      native: true,
                      MenuProps: {
                        className: styles.menu,
                      },
                    }}
                    InputProps={{
                      disableUnderline: true,
                    }}
                    inputProps={{
                      className: styles.formWrapperSelect, // the CSS class name of the wrapper element
                    }}
                    InputLabelProps={{
                      classes: {
                        root: styles.formInputLabel, // Some CSS
                        focused: styles.formInputLabelFocused,
                        filled: styles.formInputLabelFilled,
                      }
                    }}
                    variant="filled"
                    // helperText="Please select your age"
                    onChange={this.handleInputChange}
                  >
                    <option key="nil"></option>
                    {ageOptions.map(option => (
                      <option key={option.value} value={option.value}>
                        {option.name}
                      </option>
                    ))}
                  </TextField>
                </FormGroup>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="Select your mobile device"
                    select
                    name="mobileDevice"
                    id="mobile_device"
                    className={this.state.errors.mobile_device ? styles.formControl+" error" : styles.formControl}
                    value={this.state.mobileDevice}
                    SelectProps={{
                      native: true,
                      MenuProps: {
                        className: styles.menu,
                      },
                    }}
                    InputProps={{
                      disableUnderline: true,
                    }}
                    inputProps={{
                      className: styles.formWrapperSelect, // the CSS class name of the wrapper element
                    }}
                    InputLabelProps={{
                      classes: {
                        root: styles.formInputLabel, // Some CSS
                        focused: styles.formInputLabelFocused,
                        filled: styles.formInputLabelFilled,
                      }
                    }}
                    variant="filled"
                    // helperText="Please select your device"
                    onChange={this.handleInputChange}
                  >
                    <option key="nil"></option>
                    {deviceOptions.map(option => (
                      <option key={option.value} value={option.value}>
                        {option.name}
                      </option>
                    ))}
                  </TextField>
                  <span className={styles.errorMessage}>{this.state.errors.mobile_device}</span>
                </FormGroup>

                {/*<FormGroup check>
                  <Label check>
                    <Input type="checkbox" name="newsletter" checked={this.state.newsletter} onChange={this.handleCheckBox} />
                    Email Newsletter
                  </Label>
                </FormGroup> <br />*/}



                <Button className={styles.nextButton} color="primary" size="lg" block>Sign up!</Button>

              </Form>

            </div>

          </div>
        </Col>

      </Row>
    )
  }
}
