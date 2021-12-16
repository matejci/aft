
import React, {useCallback} from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { loadProgressBar } from 'axios-progress-bar'
import '!style-loader!css-loader!axios-progress-bar/dist/nprogress.css'
import Dropzone from 'react-dropzone'
// import { useDropzone } from 'react-dropzone'
import { Container, Row, Col, Button, Form, FormGroup, Label, InputGroup, InputGroupAddon, InputGroupText, Input, FormText } from 'reactstrap'
import RootRef from '@material-ui/core/RootRef'

import TextField from '@material-ui/core/TextField'
import MuiPhoneInput from 'material-ui-phone-number'

import { Player } from 'video-react'
// import '~video-react/dist/video-react.css'
import '!style-loader!css-loader!video-react/dist/video-react.css'
import VideoThumbnail from 'react-video-thumbnail'
// import b64toBlob from 'b64-to-blob'

import cx from 'classnames'
import styles from "../../css/styles.css"



function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class PartOne extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      title: "",
      description: "",
      tosAcceptance: false,
      files: [],
      mediaThumbnailFile: null,
      mediaThumbnailBlob: null,
      renderThumbnail: false,
    }

    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleCheckBox = this.handleCheckBox.bind(this)
    this.handleEmailPhoneToggle = this.handleEmailPhoneToggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.readFile = this.readFile.bind(this)
    this.processVideoThumbnail = this.processVideoThumbnail.bind(this)
  }

  componentDidMount() {
    console.log("PartOne - componentDidMount() init")

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

  onDrop(acceptedFiles, rejectedFiles) {
    // do stuff with files...
  }


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
      this.setState({ files: files, renderThumbnail: false })

      // refresh player
      this.player.load()

      this.setState({ renderThumbnail: true })

      // this.setState(this.state)
      // this.forceUpdate()
      // this.VideoThumbnail.forceUpdate()
      // this.VideoThumbnail.setState({ videoUrl: files[0]['preview'], snapshotAtTime: 2 })

      // let formPayLoad = new FormData()
      // formPayLoad.append('uploaded_image', files[0])
      // this.sendImageToController(formPayLoad)
    }
  }

  processVideoThumbnail = (thumbnail) => {
    // console.log("processVideoThumbnail: ")
    // console.log(thumbnail)

    // var contentType = 'image/png'
    // var blob = b64toBlob(thumbnail, contentType)

    fetch(thumbnail)
    .then(res => res.blob())
    .then(blob => {
      // var file = new File([blob], "thumbnail-file.png", { type: "image/png" })
      // console.log("processVideoThumbnail file => ")
      // console.log(file)

      this.setState({
        // mediaThumbnailFile: file,
        mediaThumbnailFile: thumbnail,
        // mediaThumbnailBlob: blob,
        mediaThumbnailBlob: URL.createObjectURL(blob)
      })
    })
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

  handleSubmit = (e, updatePostState) => {
    e.preventDefault()

    this.submitForm(updatePostState)
  }


  submitForm(updatePostState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    // const appToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'Content-Type': 'application/json,multipart/form-data',
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    console.log("--------- this.state.files: " + this.state.files.length + " | " + this.state.files + " ---------")

    let formData = new FormData()
    // formData.append("post[status]", this.state.status)
    formData.append("post[media_file]", this.state.files && this.state.files[0] ? this.state.files[0] : null)
    formData.append("post[media_thumbnail]", isEmpty(this.state.mediaThumbnailFile) ? null : this.state.mediaThumbnailFile)


    axios.post(`/posts.json`, formData, postHeaders)
      .then(response => {
        console.log("response: " + JSON.stringify(response))
        // this.setState({ fireRedirect: true })
        // window.location = '/'

        // proceed to the nextStep of StepWizard
        this.props.nextStep()

        // update Order Type State on index.js
        updatePostState(response.data)

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

    // const VideoThumbnailBox = (props) => (
    //   <React.Fragment>
    //     <VideoThumbnail
    //       ref={instance => { this.VideoThumbnail = instance }}
    //       videoUrl={file['preview']}
    //       renderThumbnail={false}
    //       snapshotAtTime={0}
    //       thumbnailHandler={ (thumbnail) => this.processVideoThumbnail(thumbnail) } />
    //   </React.Fragment>
    // )

    return (
      <div className={styles.usersFormBox}>
        <Row className="no-gutters">

          <Col sm="12" className="align-self-center">
            <div className={styles.containerBox}>

              <div className={styles.formBox}>

                <Form className={styles.signUpForm} onSubmit={ (e) => this.handleSubmit(e, this.props.updatePostState)}>

                  <FormGroup>
                    <Label for="image">Media File</Label>

                    { this.state.files[0] && (
                      <React.Fragment>
                        <Player
                          ref={instance => { this.player = instance }}
                          className={styles.player}
                          loop={true}
                          autoPlay={true}>
                          <source src={this.state.files[0]['preview']} />
                        </Player>

                        { this.state.renderThumbnail && (
                          <VideoThumbnail
                            ref={instance => { this.VideoThumbnail = instance }}
                            videoUrl={this.state.files[0]['preview']}
                            renderThumbnail={false}
                            snapshotAtTime={0}
                            thumbnailHandler={ (thumbnail) => this.processVideoThumbnail(thumbnail) } />
                        )}

                      </React.Fragment>
                    )}

                    <Dropzone onDrop={acceptedFiles => this.readFile(acceptedFiles)}>
                      {({getRootProps, getInputProps}) => (
                        <div {...getRootProps()} className={styles.dropzone}>
                           { this.state.files[0] ? (
                              <div className={styles.preview}>
                                {/*video: { this.state.files[0]['preview'] }


                                <img src={this.state.files[0]['preview']} className={styles.previewImage} />*/}
                                {/* <p>Drag or click again to change image</p> */}
                              </div>
                           ) : (
                              <p>Drag in a files or click to upload a video (mp4/mov only)</p>
                           )}
                          <input {...getInputProps()} />
                          <p>Drag 'n' drop some files here, or click to select files</p>
                        </div>
                      )}

                    </Dropzone>

                    <span className={styles.errorMessage}>{this.state.errors.media_file}</span>
                  </FormGroup>

                  <Button className={styles.nextButton} color="primary" size="lg" block>Upload</Button>

                </Form>

              </div>

            </div>
          </Col>

        </Row>
      </div>
    )
  }
}
