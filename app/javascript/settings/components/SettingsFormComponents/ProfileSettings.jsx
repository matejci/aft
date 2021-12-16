
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { loadProgressBar } from 'axios-progress-bar'
import '!style-loader!css-loader!axios-progress-bar/dist/nprogress.css'
import Dropzone from 'react-dropzone'
import Cropper from 'cropperjs'
import '!style-loader!css-loader!cropperjs/dist/cropper.css'
import { Container, Row, Col, Button, ButtonGroup, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'

import TextField from '@material-ui/core/TextField'
import MuiPhoneInput from 'material-ui-phone-number'

import cx from 'classnames'
import styles from "../../css/styles.css"


function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class ProfileSettings extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      user: this.props.user,
      firstName: this.props.user.first_name,
      lastName: this.props.user.last_name,
      bio: this.props.user.bio ? this.props.user.bio : "",
      username: this.props.user.username,
      tosAcceptance: false,
      files: [],
      croppedFile: null,
      cropper: null,
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.toggleBack = this.toggleBack.bind(this)
    this.readFile = this.readFile.bind(this)
  }

  componentDidMount() {
    console.log("ProfileSettings - componentDidMount() init")

    loadProgressBar()
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


  readFile(files) {
    // logic validation for existence of file(s);
    // we index at 0 here since the JSX could give us multiple files or single
    // file; either way, we get an array and we only need the first element
    // in the case of single file upload

    console.log("file uploaded: ")
    console.log(files)

    files.map(file => Object.assign(file, {
      preview: URL.createObjectURL(file)
    }))

    if (files && files[0]) {
      console.log("file uploaded: " + files[0]['preview'])
      this.setState({ files: files })
    }



    // destroy old cropper if exists
    if (this.state.cropper) {
      // cropper replace
      console.log("this.state.cropper replace")
      this.state.cropper.replace(files[0]['preview'])
      // cropper.replace("https://source.unsplash.com/random/1000x1000")
    } else {
      // cropper init
      const image = document.getElementById('previewImage')
      const cropper = new Cropper(image, {
        aspectRatio: 1 / 1,
        viewMode: 2,
        minContainerHeight: 400,
        minCanvasHeight: 400,
        // minCropBoxHeight: 300,
        responsive: true,
        crop(event) {
          // console.log(event.detail.x);
          // console.log(event.detail.y);
          // console.log(event.detail.width);
          // console.log(event.detail.height);
          // console.log(event.detail.rotate);
          // console.log(event.detail.scaleX);
          // console.log(event.detail.scaleY);
        },
      })
      this.setState({ cropper: cropper })
    }
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

    const cropper = this.state.cropper
    let croppedImage = null

    if (this.state.cropper) {
      croppedImage = cropper.getCroppedCanvas().toDataURL('image/png', 5.0)
      console.log("croppedImage")
      console.log(croppedImage)
    }

    // const croppedImage = null
    // cropper.getCroppedCanvas().toBlob((blob) => {

    //   console.log(" ")
    //   console.log("cropper.getCroppedCanvas().toBlob((blob)")
    //   console.log(blob)
    //   // this.setState({ croppedFile: blob })
    //   console.log(" ")

    //   // var reader = new FileReader()
    //   // croppedImage = reader.readAsArrayBuffer(blob)

    //   const extension = blob.type.split('/')[1];
    //   croppedImage = new File([blob], `${Date.now()}.${extension}`, {
    //     type: blob.type,
    //   })

    //   // Pass the image file name as the third parameter if necessary.
    //   // formData.append('croppedImage', blob/*, 'example.png' */);

    //   // Use `jQuery.ajax` method for example
    //   // $.ajax('/path/to/upload', {
    //   //   method: "POST",
    //   //   data: formData,
    //   //   processData: false,
    //   //   contentType: false,
    //   //   success() {
    //   //     console.log('Upload success');
    //   //   },
    //   //   error() {
    //   //     console.log('Upload error');
    //   //   },
    // })

    let formData = new FormData()
    formData.append("user[first_name]", this.state.firstName)
    formData.append("user[last_name]", this.state.lastName)
    formData.append("user[bio]", this.state.bio)
    formData.append("user[username]", this.state.username)
    if (croppedImage) {
      formData.append("user[profile_image]", croppedImage)
    }
    // formData.append("user[profile_image]", this.state.files && this.state.files[0] ? this.state.files[0] : null)

    // axios.patch(`/users/${this.props.user._id.$oid}.json`, postData, postHeaders)
    axios.patch(`/users/${this.props.user._id.$oid}.json`, formData, postHeaders)
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

    return (
      <Row className="no-gutters">

        <Col sm="12" className="align-self-center">
          <div className={styles.containerBox}>

            <div className={styles.formBox}>

              <Row className={styles.header}>
                <Col md="12">
                  <h1>
                    Profile Settings
                  </h1>
                </Col>
              </Row>

              <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updateUserState)}>

                <Row>
                  <Col md="5">

                    { this.state.files[0] ? (
                      <div className={styles.preview}>
                        <img src={this.state.files[0]['preview']} id="previewImage" className={styles.previewImage + " rounded-circle"} />
                      </div>
                    ) : (
                      !isEmpty(this.state.user.profile_image) && (
                        !isEmpty(this.state.user.profile_image.url) && (
                          <div className={styles.preview}>
                            <img src={this.state.user.profile_image.url} id="previewImage" className={styles.previewImage + " rounded-circle"} />
                          </div>
                        )
                      )
                    )}

                    <Dropzone onDrop={acceptedFiles => this.readFile(acceptedFiles)}>
                      {({getRootProps, getInputProps}) => (
                        <div {...getRootProps()} className={styles.dropzone}>
                           { this.state.files[0] ? (
                              <React.Fragment>
                              {/*
                              <div className={styles.preview}>

                                <img src={this.state.files[0]['preview']} id="previewImage" className={styles.previewImage + " rounded-circle"} />

                                <p>Drag or click again to change image</p>

                              </div>
                              */}
                              </React.Fragment>
                           ) : (
                              <p>Drag in a files or click to upload a logo (jpeg/png only)</p>
                           )}
                          <input {...getInputProps()} />
                          <p>Drag 'n' drop some files here, or click to select files</p>
                        </div>
                      )}
                    </Dropzone>

                  </Col>


                  <Col md="7">

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

                    <FormGroup className={styles.formGroup}>
                      <TextField
                        label="Bio"
                        name="bio"
                        id="bio"
                        className={this.state.errors.bio ? styles.formControl+" error" : styles.formControl}
                        type="text"
                        value={this.state.bio}
                        InputProps={{
                          disableUnderline: true,
                          className: styles.formWrapperTextArea, // the CSS class name of the wrapper element
                          multiline: true,
                          rows: 3,
                          rowsMax: 5
                        }}
                        InputLabelProps={{
                          classes: {
                            root: styles.formInputLabelSub, // Some CSS
                            focused: styles.formInputLabelSubFocused,
                            filled: styles.formInputLabelSubFilled,
                          }
                        }}
                        variant="filled"
                        onChange={this.handleInputChange} />
                      <span className={styles.errorMessage}>{this.state.errors.bio}</span>
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

                    <Button className={styles.nextButton} color="primary" size="lg">Update</Button>

                  </Col>

                </Row>


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
