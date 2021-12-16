
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'

import DateFnsUtils from '@date-io/date-fns'
import {
  MuiPickersUtilsProvider,
  KeyboardDatePicker,
} from '@material-ui/pickers'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class PartTwo extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      birthdate: "",
    }

    this.handleInputChange = this.handleInputChange.bind(this)
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

    // set limit for birthdate length
    if (value.length <= 10) {
      this.setState({
        [name]: value
      })
    }
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
        birthdate: this.state.birthdate,
      }
    }


    axios.patch(`/users/${this.props.user._id.$oid}.json`, postData, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        window.location = '/'

        // proceed to the nextStep of StepWizard
        // this.props.nextStep()

        // update Order Type State on index.js
        updateUserState(response.data)

        // console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        // console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.setState({ fireRedirect: true })
      })
  }


  render() {

    // const [selectedDate, setSelectedDate] = React.useState(new Date('2014-08-18T21:11:54'))
    // const handleDateChange = date => {
    //   setSelectedDate(date);
    // }

    return (
      <div className={styles.usersFormBox}>
        <Row className="no-gutters">

          <Col sm="12" className="align-self-center">
            <div className={styles.containerBox}>

              <div className="formBox">

                <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUserState)}>

                  {/*
                    <FormGroup className={styles.formGroup}>
                      <MuiPickersUtilsProvider utils={DateFnsUtils}>
                        <KeyboardDatePicker
                          // disableToolbar
                          variant="inline"
                          format="MM/dd/yyyy"
                          margin="normal"
                          id="date-picker-inline"
                          label="Date picker inline"
                          value={this.state.dob}
                          onChange={this.handleInputChange}
                          KeyboardButtonProps={{
                            'aria-label': 'change date',
                          }}
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
                        />
                      </MuiPickersUtilsProvider>
                      <span className={styles.errorMessage}>{this.state.errors.dob}</span>
                    </FormGroup>
                  */}

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

                  <Button className={styles.nextButton} color="primary" size="lg" block>Get started</Button>

                </Form>

              </div>

            </div>
          </Col>

        </Row>
      </div>
    )
  }
}
