
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Button, Form, FormGroup, Label, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'

import cx from 'classnames'
import styles from '../css/styles.css'

export default class LoginForm extends React.Component {

  constructor(props) {
    super(props)
    // this.state = {date: new Date()}

    this.state = {
      errors: {},
      email: "",
      password: ""
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleErrors = this.handleErrors.bind(this)
    this.loginBox = React.createRef()
    this.animateCSS = this.animateCSS.bind(this)
  }


  componentDidMount() {

  }

  componentWillUnmount() {

  }


  animateCSS = (ref, animationName, callback) => {
    const node = ref.current

    node.classList.add('animated', animationName)

    function handleAnimationEnd() {
        node.classList.remove('animated', animationName)
        node.removeEventListener('animationend', handleAnimationEnd)

        if (typeof callback === 'function') callback()
    }

    node.addEventListener('animationend', handleAnimationEnd)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })

    console.log(name + ": " + value)


  }

  handleSubmit(e) {
    // alert('A name was submitted: ' + this.state.first_name + ' ' + this.state.last_name)
    event.preventDefault()

    this.create()
  }


  create() {
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
        id: this.state.id,
        password: this.state.password,
      }
    }


    axios.post(`/sessions.json`, postData, postHeaders)
      .then(response => {
        console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        window.location = '/admin/studio'
        console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        this.animateCSS(this.loginBox, "shake")
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.handleErrors(error.response.data.error)
        // this.setState({ fireRedirect: true })
      })
  }

  handleErrors(error) {
    let thisState = this
    Object.keys(error).forEach(function(key, value) {
      console.log("key: " + key + " | " + error[key])
      if (error[key]) {
        thisState.state.errors[key] = error[key]
      } else {
        thisState.state.errors[key] = {}
      }
    })
    thisState.setState({ error: thisState.state.errors })
  }


  render() {

    return (
      <div
        ref={this.loginBox}
        className={styles.LoginBox} >
          <h2>Login</h2>
          <p>Sign in to your account</p>

          <Form  className={styles.sessionForm + " hello"} onSubmit={ (e) => this.handleSubmit(e) }>

            <FormGroup className={styles.formGroup}>
              <TextField
                label="Email or Phone"
                name="id"
                id="id"
                className={this.state.errors.id ? styles.formControl+" error" : styles.formControl}
                type="text"
                value={this.state.id}
                InputProps={{
                  autoComplete: 'nope',
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
                autoComplete="off"
                variant="filled"
                onChange={this.handleInputChange} />
              <span className={styles.errorMessage}>{this.state.errors.id}</span>
            </FormGroup>

            <FormGroup className={styles.formGroup}>
              <TextField
                label="Password"
                name="password"
                id="password"
                className={this.state.errors.password ? styles.formControl+" error" : styles.formControl}
                type="password"
                value={this.state.password}
                InputProps={{
                  autoComplete: 'nope',
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
                autoComplete="off"
                variant="filled"
                onChange={this.handleInputChange} />
              <span className={styles.errorMessage}>{this.state.errors.password}</span>
            </FormGroup>

            <Button type="submit" className={styles.loginButton} color="primary" size="lg" block>Login</Button>

            <div className={styles.session_error}>{this.state.errors.base}</div>

          </Form>

      </div>
    )
  }
}
