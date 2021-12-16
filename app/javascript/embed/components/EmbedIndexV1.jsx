
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Modal } from 'reactstrap'
import sizeMe from 'react-sizeme'
import { Scrollbars } from 'react-custom-scrollbars'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'
// import AdSense from 'react-adsense'

import EmbedBackground from './EmbedBackground'
import Post from '../../post/components/Post'

import cx from 'classnames'
import styles from '../css/styles.css'
import postStyles from '../../post/css/styles.css'
import sharedStyles from '../../shared/css/styles.css'
import imagePath from '../../shared/components/imagePath'

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class EmbedIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      post: {},
    }

    this.toggle = this.toggle.bind(this)
    this.getItem = this.getItem.bind(this)
    this.selectedPost = this.selectedPost.bind(this)
    this.syncSelectedPost = this.syncSelectedPost.bind(this)
  }

  componentDidMount() {
    console.log("class EmbedIndex V1 componentDidMount")

    // var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getItem()
  }

  componentWillUnmount() {

  }

  toggle() {
    this.setState({
      modal: !this.state.modal
    })
  }

  selectedPost = () => {
    const element = this.state.post
    const items = element ? element.items : []
    const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    return selectedPost
  }

  syncSelectedPost = (selectedPost) => {
    this.EmbedBackground.updateBackground(selectedPost.media_thumbnail.url)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
  }

  getItem = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get item
    axios.get(`/p/`+link+`.json`, getHeaders)
      .then(response => {
        const item = response.data.item
        this.setState({ post: item })

        console.log("getItem: ")
        console.log(item)
    })
  }

  render() {

    var background = ""
    if (!isEmpty(this.state.post)) {
      background = this.selectedPost().media_thumbnail.url
      this.EmbedBackground.updateBackground(background)
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

        <Container className={styles.embed + " h-100"} fluid>

          {/*<img src={ imagePath('takko-emblem.png') } className={styles.logo} />
          <div className={styles.logoBackground} style={{ background: "url('" + imagePath('takko-bg-dark.png') + "')", backgroundSize: 'cover' }}></div>*/}

          <Row className={styles.embedRow + " no-gutters row align-items-center justify-content-md-center"}>

            <EmbedBackground ref={instance => { this.EmbedBackground = instance }} background={background} />

            <Col className={styles.embedCol} xs={{ size: 10 }} md={{ size: 8 }}>

              <div className={styles.embedWrap}>
                
                { (this.state.post) ? (
                  <div className={postStyles.post}>
                    <Post post={this.state.post} syncSelectedPost={this.syncSelectedPost} />
                  </div>
                ) : (
                  <React.Fragment>
                    nothing here
                  </React.Fragment>
                )}
                  
              </div>

            </Col>

          </Row>

          <Row className={styles.embedRow + " no-gutters row align-items-center justify-content-md-center"} style={{ background: '#fff' }}>
            <Col className={styles.embedCol} xs={{ size: 12 }}>
              <p>
                description here
              </p>
            </Col>
          </Row>

        </Container>

      </React.Fragment>
    )

  }

}
