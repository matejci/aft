
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Confetti from 'react-confetti'

import SubscribersForm from './SubscribersForm'

import cx from 'classnames'
import styles from "../css/styles.css"
import imagePath from 'shared/components/imagePath'

export default class SubscriberIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      confettiStatus: false,
      toggleStatus: false
    }

    this.toggleConfetti = this.toggleConfetti.bind(this)
    this.ctaToggle = this.ctaToggle.bind(this)
    this.onBackButtonEvent = this.onBackButtonEvent.bind(this)
  }


  toggleConfetti = () => {
    console.log("toggleConfetti")
    this.setState({
      confettiStatus: !this.state.confettiStatus
    })
  }

  onBackButtonEvent = (e) => {
    e.preventDefault()

    console.log("onBackButtonEvent")
  }

  componentDidMount() {
    console.log("class SubscriberIndex componentDidMount")

    window.addEventListener("popstate", this.onBackButtonEvent)
    if (typeof(this.props.history.location.state) == 'object') {
      // this.setState({email: this.props.history.location.state.subscriber.email})
      this.props.history.replace({...this.props.history.location, state: undefined})
    }
  }

  componentWillUnmount() {
    window.removeEventListener("popstate", this.onBackButtonEvent)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
  }

  handleSubmit = (e, updateSplashState) => {
    e.preventDefault()

    this.submitForm(updateSplashState)
  }

  ctaToggle = (e) => {
    e.preventDefault()

    console.log("triggered")

    this.SubscribersForm.animateCSS(this.SubscribersForm.subscribersForm, "tada")

    // this.setState({
    //   toggleStatus: true
    // })

  }


  render() {

    // for confetti
    const ConfettiLaunch = sizeMe({
      monitorHeight: true,
      monitorWidth: true,
    })(class Example extends React.PureComponent {
      static propTypes = {
        size: PropTypes.shape({
          width: PropTypes.number,
          height: PropTypes.number
        })
      }
      render() {
        return (
          <div style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}>
            <Confetti {...this.props.size} numberOfPieces={300} />
          </div>
        )
      }
    })

    return (
      <React.Fragment>

        {this.state.confettiStatus && (
          <ConfettiLaunch />
        )}


        <Container className={styles.splash} fluid>

          <Row className={cx(styles.splashRow, styles.splashHeader)}>

            <Col xs={{ size: 6, order: 1 }} md={{ size: 6, order: 2 }} className={cx(styles.section, styles.sectionLeft)}>
              <a href="/"><img src={ imagePath('takko-emblem.png') } className={styles.takkoEmblem} /></a>
            </Col>
          </Row>

          <Row className={styles.splashRow + " h-100 justify-content-md-center"}>

            <Col xs={{ size: 12, order: 1 }} md={{ size: 6, order: 2 }} className={cx(styles.column)}>

              <h1>takko</h1>
              <h2>Get paid for your video content</h2>

              <SubscribersForm ref={instance => { this.SubscribersForm = instance }} email={this.props.location.state?.subscriber?.email} toggleConfetti={this.toggleConfetti} toggleCta={this.state.toggleStatus} />

            </Col>

          </Row>

          <p className={styles.motto}>for creators. by creators.</p>

        </Container>

      </React.Fragment>
    )

  }

}
