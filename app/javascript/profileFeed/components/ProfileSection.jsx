
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
// import { Transition, animated } from 'react-spring'
import { Transition, animated } from 'react-spring/renderprops'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import PostWrapper from './Post'

import cx from 'classnames'
import styles from '../css/styles.css'


export default class ProfileSection extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      section: props.section ? props.section : '',
      items: [],
      page: 1,
      loading: false,
      lastPage: false,
      playingElement: ''
    }

    this.sectionWrap = React.createRef()

    this.selectElement = this.selectElement.bind(this)
    this.onPaginate = this.onPaginate.bind(this)
    this.getItems = this.getItems.bind(this)
    this.handleContainerOnBottom = this.handleContainerOnBottom.bind(this)
  }

  componentDidMount() {
    console.log("class ProfileSection componentDidMount")

    this.getItems()
  }

  componentWillUnmount() {

  }

  selectElement = (element) => {
    console.log('selectElement')
    this.setState({playingElement: element})
  }

  handleContainerOnBottom = () => {
    console.log('I am at bottom in optional container! ' + Math.round(performance.now()))

    if (this.props.alertOnBottom) {
      alert('Bottom of this container hit! Too slow? Reduce "debounce" value in props')
    }
  }

  onPaginate = () => {
    this.setState({ page: this.state.page+1 }, () => {
      this.getItems()
    })

    // console.log('onPaginate')
  }

  getItems = () => {
    if (this.state.lastPage || this.state.loading) { return } // guard if last page or already loading state
    // this.setState({ loading: true }) // set loading on request

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    const section = this.state.section
    const page = this.state.page

    // get items
    axios.get(`/profiles/`+username+`/${section}/p/${page}.json`, getHeaders)
      .then(response => {
        const items = response.data

        if (items.length == 0) {
          this.setState({ lastPage: true })
        }

        this.setState({
          items: [
            ...this.state.items,
            ...items
          ],
        }, () => {
          // console.log('getItems this.setState')
          // console.log(this.state.items)
        })

        // this.setState({ loading: false }) // reset loading state
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        // this.setState({ errors: error.response.data })
      })
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
              {/*<Transition
                items={this.state.items}
                keys={element => element.item.id}
                trail={100}
                from={{ opacity: 0 }}
                enter={{ opacity: 1 }}
                leave={{ opacity: 0, display: 'none' }}
              >
                {(element) => (props) => (
                  <PostWrapper element={element} style={props} />
                )}
              </Transition>*/}
              {this.state.items.map( (element, index) => (
                <PostWrapper key={index} element={element} playingElement={this.state.playingElement} selectElement={this.selectElement} toggleModal={this.props.toggleModal} />
              ))}
          </Row>
        </div>

        <div className={styles.sectionLoading}>
          {/*{this.state.loading && (
            <Loading message='Loading..' />
          )}*/}

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
