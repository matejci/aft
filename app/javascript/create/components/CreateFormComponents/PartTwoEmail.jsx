
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col, Button, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'

import cx from 'classnames'
import styles from "../../css/styles.css"

export default class PartTwoEmail extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      email: "",
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    console.log("PartTwoEmail - componentDidMount() init")
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
        email: this.state.email
      }
    }


    axios.patch(`/users/${this.props.user._id.$oid}.json`, postData, postHeaders)
      .then(response => {
        // console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        this.props.nextStep()

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

    // const order = this.props.order

    // let orderTypeSelectOptions = this.state.orderTypes.map((orderType) =>
    //   <option key={orderType._id.$oid} value={orderType._id.$oid}>{orderType.name}</option>
    // )

    // let sourceSelectOptions = this.state.adminSources.map((adminSource) =>
    //   <option key={adminSource._id.$oid} value={adminSource._id.$oid}>{adminSource.name}</option>
    // )

    return (
      <div className={styles.usersFormBox}>
        <Row className="no-gutters">

          <Col sm="12" className="align-self-center">
            <div className={styles.containerBox}>

              <div className="formBox">

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

                  <Button className={styles.nextButton} color="primary" size="lg" block>Next</Button>

                </Form>

              </div>

            </div>
          </Col>

        </Row>
      </div>
    )
  }
}
