
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'
import sizeMe from 'react-sizeme'
import copy from 'copy-to-clipboard'
import Dropzone from 'react-dropzone'

import { withStyles } from '@material-ui/core/styles'
import Dialog from '@material-ui/core/Dialog'
import MuiDialogTitle from '@material-ui/core/DialogTitle'
import MuiDialogContent from '@material-ui/core/DialogContent'
import MuiDialogActions from '@material-ui/core/DialogActions'

import TextField from '@material-ui/core/TextField'

import cx from 'classnames'
import styles from '../../css/styles.css'

export default class Upload extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      files: [],
      name: ""
    }

    // this.onChange = this.onChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.readFile = this.readFile.bind(this)
    this.onDrop = this.onDrop.bind(this)
  }

  componentDidMount() {
    console.log("class Upload Create componentDidMount")
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

  onDrop(acceptedFiles, rejectedFiles) {
    // do stuff with files...
    console.log("onDrop init")

    if (acceptedFiles && acceptedFiles[0]) {
      console.log("file uploaded: " + acceptedFiles[0].path)
      this.setState({ files: acceptedFiles })
      // let formPayLoad = new FormData()
      // formPayLoad.append('uploaded_image', files[0])
      // this.sendImageToController(formPayLoad)
    }
  }


  readFile(files) {
    // logic validation for existence of file(s);
    // we index at 0 here since the JSX could give us multiple files or single
    // file; either way, we get an array and we only need the first element
    // in the case of single file upload

    if (files && files[0]) {
      console.log("file uploaded: " + files[0]['preview'])
      this.setState({ files: files })
      // let formPayLoad = new FormData()
      // formPayLoad.append('uploaded_image', files[0])
      // this.sendImageToController(formPayLoad)
    }
  }

  handleSubmit = (e, updateState, currentPage, limit, toggle) => {
    e.preventDefault()

    this.submitForm(updateState, currentPage, limit, toggle)
  }

  submitForm(updateState, currentPage, limit, toggle) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId,
        'Content-Type': 'application/json,multipart/form-data'
      }
    }

    console.log("--------- this.state.files: " + this.state.files.length + " | " + this.state.files + " ---------")

    let formData = new FormData()
    // formData.append("username[name]", this.state.name)
    formData.append("username[file]", this.state.files && this.state.files[0] ? this.state.files[0] : null)
    // formData.append("username[images_attributes[0][file]]", {uri: photo.uri, name: 'image.jpg', type: 'multipart/form-data'})

    axios.post(`/usernames/csv.json?page=`+currentPage+`&limit=`+limit, formData, postHeaders)
      .then(response => {
        // clear errors and form on success
        this.setState({ errors: {}, name: "" })

        // update state on usernames index
        // updateState(response)

        console.log("response => " + response.data)

        // toggle modal on success
        // toggle()

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

        <Modal isOpen={this.props.modal} toggle={ () => this.props.toggle() } className={styles.modal}>
          <ModalHeader toggle={() => this.props.toggle()}>Upload CSV</ModalHeader>
          <ModalBody>
            
            <Form className={styles.adminForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUsernamesState, this.props.currentPage, this.props.usernamesLimit, this.props.toggle) }>

              <FormGroup className={styles.formGroup}>

                <Dropzone
                  acceptedFiles=".csv"
                  onDrop={this.onDrop}>
                  {({getRootProps, getInputProps}) => (
                    <section className={this.state.files[0] ? cx(styles.dropzone, styles.aspectRatio, styles.active) : cx(styles.dropzone, styles.aspectRatio) }>
                      <span {...getRootProps()}>
                        <input {...getInputProps()} />

                        {this.state.files[0] ? (
                          <div className={styles.emptyPreviewWrap + " row align-items-center justify-content-md-center"}>
                            <p className="col-10">
                              {/* <span className={styles.checkCircleOutline}><CheckCircleOutline classes={{root: styles.checkCircleIcon}} /></span> */}
                              {this.state.files[0].path}
                            </p>
                          </div>
                        ) : (
                          <div className={styles.emptyPreviewWrap + " row align-items-center justify-content-md-center"}>
                            <p className="col-10">
                              Drag and drop a CSV file here, or click to select files
                            </p>
                          </div>
                        )}

                      </span>
                    </section>
                  )}
                </Dropzone>

                <span className="error_message">{this.state.errors.csv}</span>
              </FormGroup>

              { /* <Button className={styles.nextButton} color="primary" size="lg" block>Add</Button> */ }

            </Form>

          </ModalBody>
          <ModalFooter>
            <Button color="success" onClick={ (e) => this.handleSubmit(e, this.props.updateUsernamesState, this.props.currentPage, this.props.usernamesLimit, this.props.toggle) }>Upload CSV</Button>{' '}
            <Button color="secondary" onClick={ (e) => this.props.toggle() }>Cancel</Button>
          </ModalFooter>
        </Modal>
          
      </React.Fragment>
    )

  }

}
