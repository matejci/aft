
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Table } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'

// import Subscriber from './Subscriber'

import cx from 'classnames'
import styles from '../../css/styles.css'

export default class DashboardIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      usersTotal: 0,
      postsTotal: 0,
      takkosTotal: 0,
      viewsTotal: 0
    }

    this.getData = this.getData.bind(this)
  }

  toggle() {
    this.setState({
      isOpen: !this.state.isOpen
    })
  }

  componentDidMount() {
    console.log("class DashboardIndex componentDidMount")

    this.getData()

    console.log("HTTP-X-APP-TOKEN: " + appToken)
    console.log("APP-ID: " + appId)
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

  handleSubmit = (e, updatePageState) => {
    e.preventDefault()

    this.submitForm(updatePageState)
  }

  getData = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    var postData = {
      params: {
        current_user: this.props.currentUser
      }
    }

    // get dashboard metrics
    axios.post(`/admin/metrics/dashboard.json`, postData, postHeaders)
      .then(response => {
        const usersTotal = response.data.totalUsers
        const postsTotal = response.data.totalPosts
        const takkosTotal = response.data.totalTakkos
        const viewsTotal = response.data.totalViews
        this.setState({ usersTotal: usersTotal, postsTotal: postsTotal, takkosTotal: takkosTotal, viewsTotal: viewsTotal })
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

          <Row className={styles.pageRow + " h-100"}>

            <Col md={{ size: 12, order: 1 }} className={styles.content}>

              <div className={styles.header}>
                Dashboard
              </div>

              <Row className={styles.pageRow + " h-100"}>
                <Col md={{ size: 3, order: 1 }} className={styles.heroMetricColumn}>
                  <div className={styles.heroMetricBox}>
                    <span>{ this.state.usersTotal }</span>
                    <label>Total Users</label>
                  </div>
                </Col>

                <Col md={{ size: 3, order: 1 }} className={styles.heroMetricColumn}>
                  <div className={styles.heroMetricBox}>
                    <span>{ this.state.postsTotal }</span>
                    <label>Total Posts</label>
                  </div>
                </Col>

                <Col md={{ size: 3, order: 1 }} className={styles.heroMetricColumn}>
                  <div className={styles.heroMetricBox}>
                    <span>{ this.state.takkosTotal }</span>
                    <label>Total Takkos</label>
                  </div>
                </Col>

                <Col md={{ size: 3, order: 1 }} className={styles.heroMetricColumn}>
                  <div className={styles.heroMetricBox}>
                    <span>{ this.state.viewsTotal }</span>
                    <label>Total Views</label>
                  </div>
                </Col>
              </Row>




            </Col>

          </Row>

      </React.Fragment>
    )

  }

}
