
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText } from 'reactstrap'
import copy from 'copy-to-clipboard'

import { withStyles } from '@material-ui/core/styles'
import Dialog from '@material-ui/core/Dialog'
import MuiDialogTitle from '@material-ui/core/DialogTitle'
import MuiDialogContent from '@material-ui/core/DialogContent'
import MuiDialogActions from '@material-ui/core/DialogActions'

import StepWizard from 'react-step-wizard'
import PartOne from './SubscribersFormComponents/PartOne'
import PartTwo from './SubscribersFormComponents/PartTwo'
import PartThree from './SubscribersFormComponents/PartThree'

import cx from 'classnames'
import styles from "../css/styles.css"
export default class SubscribersForm extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      subscriber: {},
      open: false,
      link: link
    }

    this.toggleModal = this.toggleModal.bind(this)
    this.updateSubscriberState = this.updateSubscriberState.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
    this.subscribersForm = React.createRef()
    this.errorShake = this.errorShake.bind(this)
    this.resetForm = this.resetForm.bind(this)
  }

  componentDidMount() {
    console.log("class SubscribersForm componentDidMount")

    // this.animateCSS(this.subscribersForm, "tada")
    if (typeof(this.props.subscriber) == 'object') {
      this.setState({email: this.props.subscriber.email})
    }
  }

  componentWillUnmount() {

  }

  handleClose = () => {
    this.setState({ open: false })
  }

  toggleModal = () => {
    this.setState({ open: !this.state.open })
  }

  updateSubscriberState = (data) => {
    this.setState({ subscriber: data })
    console.log("updateSubscriberState(data) completed")
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
  }

  handleSubmit = (e, onToggleModal, updateAdminSourceState) => {
    e.preventDefault()

    this.submitForm(onToggleModal, updateAdminSourceState)
  }

  errorShake = () => {
    this.animateCSS(this.subscribersForm, "shake")
  }

  animateCSS = (ref, animationName, callback) => {
    // const node = document.querySelector(element)
    const node = ref.current

    node.classList.add('animated', animationName)

    function handleAnimationEnd() {
        node.classList.remove('animated', animationName)
        node.removeEventListener('animationend', handleAnimationEnd)

        if (typeof callback === 'function') callback()
    }

    node.addEventListener('animationend', handleAnimationEnd)
  }

  resetForm() {
    this.setState({ toggleKey: !this.state.toggleKey })
    this.props.toggleConfetti();
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

    const Nav = (props) => {
      // parse from otherProps
      // var {size, updateSizeState, ...otherProps} = props

      const dots = []
      for (let i = 1; i <= props.totalSteps; i += 1) {
          const isActive = props.currentStep === i
          dots.push((
              <span
                  key={`step-${i}`}
                  className={`${styles.dot} ${isActive ? styles.active : ''}`}
                  // onClick={() => props.goToStep(i)}
              >&bull;</span>
          ))
      }

      return (
          <div className={styles.nav}>{dots}</div>
      )
    }

    return (
      <div ref={this.subscribersForm} key={this.state.toggleKey} className={this.props.toggleCta ? styles.subscribersForm+" h-100 animated tada" : styles.subscribersForm }>

        <Row className="h-100">

          <Col md={{ size: 10, order: 2, offset: 1 }} lg={{ size: 8, order: 2, offset: 2 }} xl={{ size: 6, order: 2, offset: 3 }} className={styles.subscribersBoxWrap}>
            <div className={styles.subscribersFormBox}>

              <StepWizard
                className={"h-100"}
                // nav={<Nav />}
                // isLazyMount={true}
                isHashEnabled={false}>

                <PartOne subscriber={this.state.subscriber} email={this.props.email} updateSubscriberState={this.updateSubscriberState} link={this.state.link} errorShake={this.errorShake} />

                <PartTwo subscriber={this.state.subscriber} updateSubscriberState={this.updateSubscriberState} errorShake={this.errorShake} />

                <PartThree subscriber={this.state.subscriber} updateSubscriberState={this.updateSubscriberState} toggleModal={this.toggleModal} toggleConfetti={this.props.toggleConfetti} errorShake={this.errorShake} />

              </StepWizard>

            </div>
          </Col>

        </Row>

        <Dialog
          onClose={this.handleClose}
          classes={{
            root: styles.modal,
            paper: styles.paper,
          }}
          fullWidth={true}
          maxWidth = {'sm'}
          aria-labelledby="customized-dialog-title"
          open={this.state.open}
          onBackdropClick={this.resetForm}
          onEscapeKeyDown={this.resetForm}
        >
          <div className={styles.modalContent}>
            <Row className="justify-content-md-center align-self-center">
              <Col md="12">

                <h3>Congrats, you're #{this.state.subscriber.position} in line!</h3>

                <p>Share this link and get early access to claim your username!</p>

                <div className={styles.shareLink}>
                  <Input
                  name="link"
                  className={styles.formControl}
                  type="text"
                  defaultValue={"http://takkoapp.com/s/"+this.state.subscriber.link} />

                  <Button color="secondary" size="sm" className={styles.shareCopyBtn} onClick={ () => copy("http://takkoapp.com/s/"+this.state.subscriber.link) }>Copy</Button>
                </div>
              </Col>
            </Row>
          </div>
        </Dialog>

      </div>
    )

  }

}
