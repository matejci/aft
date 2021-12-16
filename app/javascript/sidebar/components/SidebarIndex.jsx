
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring'
import { ListGroup, ListGroupItem, Dropdown, DropdownItem, DropdownToggle, DropdownMenu } from 'reactstrap'
import { Scrollbars } from 'react-custom-scrollbars'

// import Product from './Product'

import cx from 'classnames'
import styles from "../css/styles.css"
import imagePath from 'shared/components/imagePath'

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

    // get product options
    // axios.get(`/products.json`)
    //   .then(response => {
    //     const products = response.data.products
    //     this.setState({ products: products })
    //     // console.log("productOptions: " + JSON.stringify(productOptions))
    // })
    //   .catch(error => {
    //     console.error("error: " + error)
    //     console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
    //     this.setState({ errors: error.response.data })
    //     // redirect to root
    //     if (error.response.data.redirect) {
    //       window.location = error.response.data.root_url
    //     }
    // })
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


  render() {

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


    return (
      <div className="h-100">

        <a href="/"><img src={ imagePath('takko-logo.png') } className={styles.logo} /></a>

        <ListGroup className={styles.listGroup} flush>
          <ListGroupItem active={this.props.active=="dashboard"} className={styles.listGroupItem} tag="a" href="#" action>
            Top Likes
          </ListGroupItem>
          <ListGroupItem active={this.props.active=="designs"} className={styles.listGroupItem} tag="a" href="#" action>
            Top Viewed
          </ListGroupItem>
          <ListGroupItem active={this.props.active=="pages"} className={styles.listGroupItem} tag="a" href="#" action>
            Top Followed
          </ListGroupItem>
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
                <DropdownItem header>Creator HQ</DropdownItem>
                <DropdownItem className={styles.dropdownItem}>Dashboard</DropdownItem>
                <DropdownItem href="/create" className={styles.dropdownItem}>Upload</DropdownItem>
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
