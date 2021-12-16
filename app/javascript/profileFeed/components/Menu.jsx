
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
// import { Transition, animated } from 'react-spring'
import { Transition, animated } from 'react-spring/renderprops'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import Post from './Post'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

export default class Menu extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      section: props.section ? props.section : '',
      items: [],
      page: 1,
      loading: false,
      lastPage: false
    }

    this.sectionWrap = React.createRef()

    this.handleContainerOnBottom = this.handleContainerOnBottom.bind(this)
  }

  componentDidMount() {
    console.log("class Menu componentDidMount")
  }

  componentWillUnmount() {

  }

  handleContainerOnBottom = () => {
    console.log('I am at bottom in optional container! ' + Math.round(performance.now()))

    if (this.props.alertOnBottom) {
      alert('Bottom of this container hit! Too slow? Reduce "debounce" value in props')
    }
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
      <div className={this.props.isActive ? cx(styles.sectionWrap, styles.active) : styles.sectionWrap}>
        <div ref={this.sectionWrap} className={styles.innerSection}>
          <Row className={styles.sectionRow}>

            <div className={styles.menuAssets}>
              <img src={imagePath("menu-01.png")} className="img-fluid" />
            </div>

            <div className={styles.menuAssets}>
              <img src={imagePath("menu-02.png")} className="img-fluid" />
            </div>

          </Row>
        </div>

        <div className={styles.sectionLoading}>
          {this.state.loading && (
            <Loading message='Loading..' />
          )}

          <div className={styles.endMessage}>
            {this.state.lastPage && (
              <p>You have reached the end!</p>
            )}
          </div>
        </div>
      </div>
    )
  }

}
