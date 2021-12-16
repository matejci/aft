
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

import Invitation from './Invitation'

import cx from 'classnames'
import styles from '../css/styles.css'

export default class AdminInvitationsIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      currentUser: currentUser,
      isOpen: false,
      invitations: [],
      invitationsTotal: 0,
      invitationsTotalPages: 0,
      invitationsLimit: 75,
      current: 1,
    }

    this.getInvitations = this.getInvitations.bind(this)
    this.onChange = this.onChange.bind(this)
    this.updateInvitationsState = this.updateInvitationsState.bind(this)
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
    }, this.getInvitations(page, this.state.invitationsLimit))
  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })

    console.log("updateCurrentUserState done")
  }

  componentDidMount() {
    console.log("class AdminInvitationsIndex componentDidMount")

    var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getInvitations(this.state.current, this.state.invitationsLimit)
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

  updateInvitationsState(data) {
    this.setState({ invitations: data })
    console.log("updateInvitationsState(data) completed")
  }

  getInvitations = (current, limit) => {
    // clear invitations
    this.setState({ invitations: [] })

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get invitations
    axios.get(`/invitations.json?page=`+current+`&limit=`+limit, getHeaders)
      .then(response => {
        const invitations = response.data.invitations
        const invitationsTotal = response.data.invitationsTotal
        const invitationsTotalPages = response.data.invitationsTotalPages
        this.setState({ invitations: invitations, invitationsTotal: invitationsTotal, invitationsTotalPages: invitationsTotalPages })
    })
  }


  render() {

    // const invitationsKeys = this.state.invitations.length ? this.state.invitations.map(invitation => invitation._id.$oid) : []

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

        <Navbar color="dark" dark expand="md" className={styles.navbar}>
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

                Invitation Total: { this.state.invitationsTotal }

              </div>


              <Table>
                <thead>
                  <tr>
                    <th>ID</th>
                    <th style={{ minWidth: 200 }}>created_at</th>
                    <th style={{ minWidth: 200 }}>claimed_date</th>
                    <th>claimed</th>
                    <th>ip_address</th>
                    <th>user_agent</th>
                    <th>invite_code</th>
                    <th>status</th>
                    <th>email_sent</th>
                    <th>email_used</th>
                    <th>invited_by</th>
                    <th>invited_type</th>
                    <th>attempts</th>
                    <th>number_of_attempts</th>
                    <th>device_name</th>
                    <th>device_type</th>
                    <th>device_client_name</th>
                    <th>device_client_full_version</th>
                    <th>device_os</th>
                    <th>device_os_full_version</th>
                    <th>device_client_known</th>
                  </tr>
                </thead>
                <tbody>
                  <Transition
                    items={this.state.invitations}
                    keys={item => item._id.$oid}
                    // trail={200}
                    from={{ opacity: 0, height: 0 }}
                    enter={{ opacity: 1, height: 50 }}
                    leave={{ opacity: 0, height: 0, display: 'none' }}
                  >
                    { item => props => (
                      <Invitation
                        style={props}
                        invitation={item}
                        key={item._id.$oid}
                        updateInvitationsState={this.updateInvitationsState}
                      />
                    )}
                  </Transition>
                </tbody>
              </Table>

              <Pagination onChange={this.onChange} current={this.state.current} pageSize={this.state.invitationsLimit} total={this.state.invitationsTotal} />

            </Col>

          </Row>
        </Container>
      </React.Fragment>
    )

  }

}
