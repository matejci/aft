
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import { Container, Row, Col, Button, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'

import cx from 'classnames'
import styles from "../../css/styles.css"
import api from '../../../util/api'

export default class PartOne extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      email: "",
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
  }

  componentDidMount() {
    console.log("PartOne - componentDidMount() init")

    // this.props.goToStep(3)
    if (typeof(this.props.email) == 'string') {
      this.setState({email: this.props.email}, () => {
        document.getElementById('email_form').getElementsByTagName('button')[0].click()
      })
    }
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

  handleSubmit = (e, updateSubscriberState) => {
    e.preventDefault()

    this.submitForm(updateSubscriberState)
  }


  submitForm(updateSubscriberState) {
    var postData = {
      subscriber: {
        email: this.state.email,
        referral: this.props.link
      }
    }

    api.post(`/subscribers.json`, postData)
      .then(response => {
        console.log("response: " + response)
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        this.props.nextStep()

        // update Order Type State on index.js
        updateSubscriberState(response.data)

        // console.log("JSON.parse success => " + JSON.stringify(response.data))
        // this.setState({ quote: response.data })
      })
      .catch(error => {
        this.props.errorShake()
        console.error("error: " + error)
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
      <Row>

        <Col sm="12" className="align-self-center">
          <div className={styles.containerBox}>

            <div className={styles.formBox}>

              <p className={styles.callToAction}>{/*Get on the list*/}</p>

              <Form id='email_form' className="subscribersForm" onSubmit={ (e) => this.handleSubmit(e, this.props.updateSubscriberState)}>

                <FormGroup className={styles.formGroup}>
                  <TextField
                    label="Email"
                    name="email"
                    id="email"
                    className={this.state.errors.email ? styles.formControl+" error" : styles.formControl}
                    type="text"
                    value={this.state.email}
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
                  <span className={styles.errorMessage}>{this.state.errors.email}</span>
                </FormGroup>

                <Button className={styles.nextButton} color="primary" size="lg" block={true}>Next</Button>

              </Form>

            </div>

          </div>
        </Col>

      </Row>
    )
  }
}
