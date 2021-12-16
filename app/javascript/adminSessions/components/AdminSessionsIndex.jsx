
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
// import { Transition } from 'react-spring'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Table } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Confetti from 'react-confetti'
import { currentUserSession } from '../../currentUser/components/CurrentUser'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css';

import Session from './Session'

import cx from 'classnames'
import styles from '../css/styles.css'

export default class AdminIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      currentUser: currentUser,
      isOpen: false,
      sessions: [],
      sessionsTotal: 0,
      sessionsTotalPages: 0,
      sessionsLimit: 75,
      current: 1,
    }

    this.getSessions = this.getSessions.bind(this)
    this.onChange = this.onChange.bind(this)
    this.updateSessionsState = this.updateSessionsState.bind(this)
    this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
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
    }, this.getSessions(page, this.state.sessionsLimit))
  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })

    console.log("updateCurrentUserState done")
  }

  componentDidMount() {
    console.log("class AdminIndex componentDidMount")

    var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getSessions(this.state.current, this.state.sessionsLimit)
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

  updateSessionsState(data) {
    this.setState({ sessions: data })
    console.log("updateSessionsState(data) completed")
  }

  getSessions = (current, limit) => {
    // clear sessions
    this.setState({ sessions: [] })

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get sessions
    axios.get(`/sessions.json?page=`+current+`&limit=`+limit, getHeaders)
      .then(response => {
        const sessions = response.data.sessions
        const sessionsTotal = response.data.sessionsTotal
        const sessionsTotalPages = response.data.sessionsTotalPages
        this.setState({ sessions: sessions, sessionsTotal: sessionsTotal, sessionsTotalPages: sessionsTotalPages })
    })
  }


  render() {

    // const sessionsKeys = this.state.sessions.length ? this.state.sessions.map(session => session._id.$oid) : []

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

        <Navbar color="light" light expand="md" className={styles.navbar}>
          <NavbarBrand href="/" className={styles.navLogo}>takko</NavbarBrand>
          <NavbarToggler onClick={this.toggle} />
          <Collapse isOpen={this.state.isOpen} navbar>
            <Nav className="ml-auto" navbar>
            {/*
              <NavItem>
                <NavLink href="/components/">Components</NavLink>
              </NavItem>
              <NavItem>
                <NavLink href="https://github.com/reactstrap/reactstrap">GitHub</NavLink>
              </NavItem>
            */}
              <UncontrolledDropdown nav inNavbar>
                <DropdownToggle nav caret>
                  { this.state.currentUser.email }
                </DropdownToggle>
                <DropdownMenu right>
                  {/*<DropdownItem>
                    Option 1
                  </DropdownItem>
                  <DropdownItem>
                    Option 2
                  </DropdownItem>
                  <DropdownItem divider />*/}
                  <DropdownItem color="primary">
                    <a className={styles.navLink} href="/signout">Signout</a>
                  </DropdownItem>
                </DropdownMenu>
              </UncontrolledDropdown>
            </Nav>
          </Collapse>
        </Navbar>

        <Container className={styles.splash} fluid>

          <Row className={styles.splashRow + " h-100"}>

            <Col md={{ size: 12, order: 1 }} className={styles.content} style={{overflow: 'scroll'}}>

              <div className={styles.header}>

                Sessions Total: { this.state.sessionsTotal }

              </div>


              <Table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th style={{ minWidth: 200 }}>created_at</th>
                    <th style={{ minWidth: 200 }}>last_login</th>
                    <th style={{ minWidth: 200 }}>last_activity</th>
                    <th>ip_address</th>
                    <th>user</th>
                    <th>access_token</th>
                    <th>token</th>
                    <th>user_agent</th>
                    <th>exp_date</th>
                    <th>status</th>
                    <th>live</th>
                    <th>device_name</th>
                    <th>device_type</th>
                    <th>device_client_name</th>
                    <th>device_client_full_version</th>
                    <th>device_os</th>
                    <th>device_os_full_version</th>
                    <th>device_client_known</th>
                    <th>app</th>
                  </tr>
                </thead>
                <tbody>
                  <Transition
                    items={this.state.sessions}
                    keys={item => item._id.$oid}
                    // trail={200}
                    from={{ opacity: 0, height: 0 }}
                    enter={{ opacity: 1, height: 50 }}
                    leave={{ opacity: 0, height: 0, display: 'none' }}
                  >
                    { item => props => (
                      <Session
                        style={props}
                        session={item}
                        key={item._id.$oid}
                        updateSessionsState={this.updateSessionsState}
                      />
                    )}
                  </Transition>
                </tbody>
              </Table>

              <Pagination onChange={this.onChange} current={this.state.current} pageSize={this.state.sessionsLimit} total={this.state.sessionsTotal} />

            </Col>

          </Row>
        </Container>
      </React.Fragment>
    )

  }

}
