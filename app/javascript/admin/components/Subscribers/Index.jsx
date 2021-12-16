
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Table } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'

import Subscriber from './Subscriber'

import cx from 'classnames'
import styles from '../../css/styles.css'

export default class SubscriberIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      isOpen: false,
      subscribers: [],
      subscribersTotal: 0,
      subscribersTotalPages: 0,
      subscribersLimit: 75,
      current: 1,
    }

    this.getSubscribers = this.getSubscribers.bind(this)
    this.onChange = this.onChange.bind(this)
    this.updateSubscribersState = this.updateSubscribersState.bind(this)
  }

  toggle() {
    this.setState({
      isOpen: !this.state.isOpen
    })
  }

  onChange = (page) => {
    console.log(page)
    this.setState({
      current: page,
    }, this.getSubscribers(page, this.state.subscribersLimit))
  }

  componentDidMount() {
    console.log("class SubscriberIndex componentDidMount")

    this.getSubscribers(this.state.current, this.state.subscribersLimit)
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

  handleSubmit = (e, updateSplashState) => {
    e.preventDefault()

    this.submitForm(updateSplashState)
  }

  updateSubscribersState(data) {
    this.setState({ subscribers: data })
    console.log("updateSubscribersState(data) completed")
  }

  getSubscribers = (current, limit) => {
    // clear subscribers
    this.setState({ subscribers: [] })

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get subscribers
    axios.get(`/subscribers.json?page=`+current+`&limit=`+limit, getHeaders)
      .then(response => {
        const subscribers = response.data.subscribers
        const subscribersTotal = response.data.subscribersTotal
        const subscribersTotalPages = response.data.subscribersTotalPages
        this.setState({ subscribers: subscribers, subscribersTotal: subscribersTotal, subscribersTotalPages: subscribersTotalPages })
    })
  }


  render() {

    // const subscribersKeys = this.state.subscribers.length ? this.state.subscribers.map(subscriber => subscriber._id.$oid) : []

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

          <Row className={styles.splashRow + " h-100"}>

            <Col md={{ size: 12, order: 1 }} className={styles.content} style={{overflow: 'scroll'}}>

              <div className={styles.header}>

                Subscribers Total: { this.state.subscribersTotal }

              </div>


              <Table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th style={{ minWidth: 200 }}>Created At</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Device</th>
                    <th>Link</th>
                    <th>Queue</th>
                    <th>Position</th>
                    <th>IP Address</th>
                    <th>User Agent</th>
                    <th>Email Status</th>
                    <th style={{ minWidth: 200 }}>Email Date</th>
                    <th>Referred By</th>
                  </tr>
                </thead>
                <tbody>
                  <Transition
                    items={this.state.subscribers}
                    keys={item => item.id}
                    // trail={200}
                    from={{ opacity: 0, height: 0 }}
                    enter={{ opacity: 1, height: 50 }}
                    leave={{ opacity: 0, height: 0, display: 'none' }}
                  >
                    { item => props => (
                      <Subscriber
                        style={props}
                        subscriber={item}
                        key={item.id}
                        updateSubscribersState={this.updateSubscribersState}
                      />
                    )}
                  </Transition>
                </tbody>
              </Table>

              <Pagination onChange={this.onChange} current={this.state.current} pageSize={this.state.subscribersLimit} total={this.state.subscribersTotal} />

            </Col>

          </Row>
          
      </React.Fragment>
    )

  }

}
