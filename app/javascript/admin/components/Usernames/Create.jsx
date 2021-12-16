
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'
import sizeMe from 'react-sizeme'
import copy from 'copy-to-clipboard'

import { withStyles } from '@material-ui/core/styles'
import Dialog from '@material-ui/core/Dialog'
import MuiDialogTitle from '@material-ui/core/DialogTitle'
import MuiDialogContent from '@material-ui/core/DialogContent'
import MuiDialogActions from '@material-ui/core/DialogActions'

import TextField from '@material-ui/core/TextField'

import Upload from './Upload'

import cx from 'classnames'
import styles from '../../css/styles.css'

export default class Create extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      nestedModal: false,
      name: ""
    }

    // this.onChange = this.onChange.bind(this)
    this.toggle = this.toggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  toggle() {
    this.setState({
      nestedModal: !this.state.nestedModal
    })
  }

  componentDidMount() {
    console.log("class Usernames Create componentDidMount")
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

  handleSubmit = (e, updateState, currentPage, limit, toggle) => {
    e.preventDefault()

    this.submitForm(updateState, currentPage, limit, toggle)
  }

  submitForm(updateState, currentPage, limit, toggle) {
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
      username: {
        name: this.state.name
      }
    }

    axios.post(`/usernames.json?page=`+currentPage+`&limit=`+limit, postData, postHeaders)
      .then(response => {
        // clear errors and form on success
        this.setState({ errors: {}, name: "" })

        // update state on usernames index
        updateState(response)

        // toggle modal on success
        toggle()

      })
      .catch(error => {
        // this.props.errorShake()
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
        // this.setState({ fireRedirect: true })
      })
  }


  render() {

    function isEmpty(obj) {
      for(var key in obj) {
          if(obj.hasOwnProperty(key))
              return false
      }
      return true
    }

    const Loading = (props) => {
      return (
        <div {...props} className={styles.spinnerLoading}>
          <Row className="justify-content-md-center align-items-center h-100">
            <Col md="5">
              <div className={styles.spinner}>
                <div className={styles.doubleBounce1}></div>
                <div className={styles.doubleBounce2}></div>
              </div>
              <p>{props.message}</p>
            </Col>
          </Row>
        </div>
      )
    }

    return (
      <React.Fragment>

        <Modal isOpen={this.props.isOpen} toggle={ () => this.props.toggle() } className={styles.modal}>
          <ModalHeader toggle={() => this.props.toggle()}>Add Username</ModalHeader>
          <ModalBody>
            
            <Form className={styles.adminForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUsernamesState, this.props.currentPage, this.props.usernamesLimit, this.props.toggle) }>

              <FormGroup className={styles.formGroup}>
                <TextField
                  label="Username"
                  name="name"
                  id="name"
                  className={this.state.errors.name ? styles.formControl+" error" : styles.formControl}
                  type="text"
                  value={this.state.name}
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
                  onChange={ (e) => this.handleInputChange(e) } />
                <span className={styles.errorMessage}>{this.state.errors.name}</span>
              </FormGroup>

              { /* <Button className={styles.nextButton} color="primary" size="lg" block>Add</Button> */ }

            </Form>

          </ModalBody>
          <ModalFooter>
            <Button color="primary" onClick={ (e) => this.handleSubmit(e, this.props.updateUsernamesState, this.props.currentPage, this.props.usernamesLimit, this.props.toggle) }>Add</Button>{' '}
            <Button color="success" onClick={ (e) => this.toggle() }>Upload</Button>
            <Button color="secondary" onClick={ (e) => this.props.toggle() }>Cancel</Button>
          </ModalFooter>

          <Upload modal={this.state.nestedModal} toggle={this.toggle} currentPage={this.props.currentPage} usernamesLimit={this.props.usernamesLimit} updateUsernamesState={this.props.updateUsernamesState} />

        </Modal>
          
      </React.Fragment>
    )

  }

}
