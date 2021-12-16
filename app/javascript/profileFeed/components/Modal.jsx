
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
// import { Transition, animated } from 'react-spring'
import { Transition, animated } from 'react-spring/renderprops'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import Post from '../../post/components/Post'

import cx from 'classnames'
import styles from '../css/styles.css'
import postStyles from '../../post/css/styles.css'


export default class Modal extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      element: {},
      isActive: false,
    }

    this.show = this.show.bind(this)
    this.hide = this.hide.bind(this)
    this.syncSelectedPost = this.syncSelectedPost.bind(this)
  }

  componentDidMount() {
    console.log("class Modal componentDidMount")
  }

  componentWillUnmount() {

  }

  show = (element) => {
    this.setState({ isActive: !this.state.isActive, element: element })
  }

  hide = (e) => {
    e.preventDefault()

    this.setState({ isActive: false, element: {} })
  }

  syncSelectedPost = (selectedPost) => {
    console.log("Modal syncSelectedPost")
  }

  render() {

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
      <div className={this.state.isActive ? cx(styles.modal, styles.active) : styles.modal}>

        {/*<a href="#" onClick={ (e) => this.hide(e) }>Back</a>*/}

        <a href="#" onClick={ (e) => this.hide(e) } className={styles.backTopModalBtn}>Back</a>

        <hr />

        <Container className={styles.profileContainer}>
          <Row className={styles.profileRow + " no-gutters"}>

            <Col md={{ size: 12 }}>

              {(this.state.element) && (
                <React.Fragment>
                  <div className={cx(postStyles.post, styles.post, styles.postModal)}>
                    <Post post={this.state.element.item} />
                  </div>
                </React.Fragment>
              )}

            </Col>

          </Row>
        </Container>

        <a href="#" onClick={ (e) => this.hide(e) } className={styles.backModalBtn}>Back</a>

      </div>
    )
  }

}
