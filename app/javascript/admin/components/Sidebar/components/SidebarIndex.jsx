import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import _ from 'lodash'
import axios from 'axios'
import { Transition } from 'react-spring'
import { ListGroup, ListGroupItem, Dropdown, DropdownItem, DropdownToggle, DropdownMenu } from 'reactstrap'
import { Scrollbars } from 'react-custom-scrollbars'

// import Product from './Product'

import cx from 'classnames'
import styles from "../css/styles.css"
// import '!style-loader!css-loader!bootstrap/dist/css/bootstrap.css'


function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class SidebarIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      products: {},
      dropdownOpen: false
    }

    this.toggle = this.toggle.bind(this)
    this.updateProductsState = this.updateProductsState.bind(this)
  }

  componentDidMount() {
    console.log("class SidebarIndex componentDidMount")
  }

  componentWillUnmount() {

  }

  toggle() {
    this.setState({
      dropdownOpen: !this.state.dropdownOpen
    })
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

  updateProductsState = (data) => {
    this.setState({ product: data })
    console.log("updateProductsState(data) completed")
  }

  listItem = (item) => {
    var itemProps

    switch(item) {
      case 'supported_versions':
        itemProps = { href: `/admin/studio/${_.snakeCase(item)}` }
        break;
      case 'pools':
        itemProps = { href: `/admin/studio/${_.snakeCase(item)}`, onClick: null }
        break;
      case 'curation':
        itemProps = { href: '/admin/curated_posts', onClick: null }
        break;
      case 'reports':
        itemProps = { href: '/admin/reports', onClick: null }
        break;
      case 'creator_program':
        itemProps = { href: '/admin/creator_program', onClick: null }
        break;
      case 'boost_list':
        itemProps = { href: '/admin/boost_list/index', onClick: null }
        break;
      case 'subscribers':
        itemProps = { href: '/subscribers', onClick: null }
        break;
      default:
        itemProps = { href: `/admin/${item}`, onClick: null }
    }

    return(
      <ListGroupItem
        key={item}
        active={this.props.active == item}
        className={styles.listGroupItem}
        tag="a"
        href="#"
        onClick={(e) => this.props.updatePage(e, item)}
        action
        {...itemProps}>
        <span>{_.startCase(item)}</span>
      </ListGroupItem>
    )
  }

  render() {
    var itemProps, reactRoute

    const products = this.state.products
    const productsKeys = products.length ? products.map(product => product._id.$oid) : []

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

    const listItems = [
      "dashboard", "users", "content", "pools", "payouts", "subscribers", "invitations",
      "usernames", "curation", "reports", 'creator_program', 'banners', 'supported_versions', 'boost_list', 'contests'
    ].map((item) => (this.listItem(item)))

    return (
      <div className="h-100">

        <a href="/admin/studio" className={styles.adminStudioLogoNavLogo}><span className={styles.adminStudioLogo}>takko</span></a>

        <ListGroup className={styles.listGroup} flush>
          {listItems}
        </ListGroup>

        { (isEmpty(this.props.currentUser) || isEmpty(this.props.currentUser._id)) ? (
          <div></div>
        ) : (
          <div className="nav">
            <Dropdown nav inNavbar={true} direction={'up'} className={styles.buttonDropdown} isOpen={this.state.dropdownOpen} toggle={this.toggle}>
              <DropdownToggle nav caret>
                {this.props.currentUser.email}
              </DropdownToggle>
              <DropdownMenu className={styles.dropdownMenu}>
                <DropdownItem header>Admin Studio</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Dashboard</DropdownItem>
                <DropdownItem header>Account</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Payments</DropdownItem>
                <DropdownItem href="/settings" className={styles.dropdownItem}>Settings</DropdownItem>
                <DropdownItem divider />
                <DropdownItem href="/signout" className={styles.dropdownItemLast}>
                  Signout
                </DropdownItem>
              </DropdownMenu>
            </Dropdown>
          </div>
        )}

      </div>
    )

  }

}
