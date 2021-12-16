
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Table, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'

import Username from './Username'
import Create from './Create'

import cx from 'classnames'
import styles from '../../css/styles.css'

export default class UsernamesIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      isOpen: false,
      usernames: [],
      usernamesTotal: 0,
      usernamesTotalPages: 0,
      usernamesLimit: 25,
      current: 1,
    }

    this.toggle = this.toggle.bind(this)
    this.getUsernames = this.getUsernames.bind(this)
    this.onChange = this.onChange.bind(this)
    this.updateUsernamesState = this.updateUsernamesState.bind(this)
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
    }, this.getUsernames(page, this.state.usernamesLimit))
  }

  componentDidMount() {
    console.log("class UsernamesIndex componentDidMount")

    this.getUsernames(this.state.current, this.state.usernamesLimit)
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

  handleSubmit = (e, updateState) => {
    e.preventDefault()

    this.submitForm(updateState)
  }

  updateUsernamesState(response) {
    const usernames = response.data.usernames
    const usernamesTotal = response.data.usernamesTotal
    const usernamesTotalPages = response.data.usernamesTotalPages
    this.setState({ usernames: usernames, usernamesTotal: usernamesTotal, usernamesTotalPages: usernamesTotalPages })

    console.log("updateUsernamesState(data) completed")
  }

  getUsernames = (current, limit) => {
    // clear usernames
    this.setState({ usernames: [] })

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get usernames
    axios.get(`/usernames.json?page=`+current+`&limit=`+limit, getHeaders)
      .then(response => {
        const usernames = response.data.usernames
        const usernamesTotal = response.data.usernamesTotal
        const usernamesTotalPages = response.data.usernamesTotalPages
        this.setState({ usernames: usernames, usernamesTotal: usernamesTotal, usernamesTotalPages: usernamesTotalPages })
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

          <Row className={styles.splashRow + " h-100"}>

            <Col md={{ size: 12, order: 1 }} className={styles.content} style={{overflow: 'scroll'}}>

              <div className={styles.header}>

                Usernames Total: { this.state.usernamesTotal }

              </div>

              <div className={styles.subheader}>

                <Button color="secondary" size="sm" onClick={() => this.toggle()}>Add Username</Button>

              </div>

              <Create isOpen={this.state.isOpen} toggle={this.toggle} currentPage={this.state.current} usernamesLimit={this.state.usernamesLimit} updateUsernamesState={this.updateUsernamesState} />

              <Table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th style={{ minWidth: 200 }}>Created At</th>
                    <th>Identity</th>
                    <th>Status</th>
                    <th>Type</th>
                  </tr>
                </thead>
                <tbody>
                  <Transition
                    items={this.state.usernames}
                    keys={item => item.id}
                    // trail={200}
                    from={{ opacity: 0, height: 0 }}
                    enter={{ opacity: 1, height: 50 }}
                    leave={{ opacity: 0, height: 0, display: 'none' }}
                  >
                    { item => props => (
                      <Username
                        style={props}
                        username={item}
                        key={item.id}
                        updateUsernamesState={this.updateUsernamesState}
                      />
                    )}
                  </Transition>
                </tbody>
              </Table>

              <Pagination onChange={this.onChange} current={this.state.current} pageSize={this.state.usernamesLimit} total={this.state.usernamesTotal} />

            </Col>

          </Row>
          
      </React.Fragment>
    )

  }

}
