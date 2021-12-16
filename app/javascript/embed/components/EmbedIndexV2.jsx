
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

import useMeasure from 'react-use-measure'

import EmbedBackground from './EmbedBackground'
import EmbedBottom from './EmbedBottom'
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
    this.bottomBoundsHeight = 0

    this.toggle = this.toggle.bind(this)
    this.getItem = this.getItem.bind(this)
    this.selectedPost = this.selectedPost.bind(this)
    this.syncSelectedPost = this.syncSelectedPost.bind(this)
  }

  componentDidMount() {
    // console.log("class EmbedIndex componentDidMount")

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

    if (this.EmbedBottom) {
      this.EmbedBottom.updateSelectedPost(selectedPost)
    }
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

        // console.log("getItem: ")
        // console.log(item)
    })
  }

  render() {

    // var background = ""
    // if (!isEmpty(this.state.post)) {
    //   background = this.selectedPost().media_thumbnail.url
    //   console.log("render() background: " + JSON.stringify(background))

    //   this.EmbedBackground.updateBackground(background)
    // }

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

    const Takko = () => {
      const [ref, bounds] = useMeasure()
      const [bottomRef, bottomBounds] = useMeasure()

      const width = Math.round(bounds.width)
      const height = Math.round(bounds.height)
      const borderRadius = width/15

      const bottomWidth = Math.round(bottomBounds.width)
      const bottomHeight = Math.round(this.bottomBoundsHeight == 0 ? bottomBounds.height : this.bottomBoundsHeight)

      const diffHeight = height-bottomHeight
      const verticalPadding = 50
      const dynamicHeight = (diffHeight-verticalPadding*2)
      const dynamicWidth = (9/16)*dynamicHeight

      if (this.bottomBoundsHeight == 0 && !isEmpty(this.state.post)) {
        this.bottomBoundsHeight = bottomHeight
      }

      return (
        <React.Fragment>
          <div ref={ref} className={styles.embedTortilla}>

            <div className={styles.main} style={{ height: diffHeight }}>

              <EmbedBackground ref={instance => { this.EmbedBackground = instance }} style={{width: width, height: height}} />

              <div className={cx(postStyles.post, styles.post)} style={{ width: dynamicWidth, height: dynamicHeight }}>
                <Post post={this.state.post} syncSelectedPost={this.syncSelectedPost} selectedPost={(this.EmbedBottom) ? this.EmbedBottom.selectedPost : {}} />
              </div>
            </div>

            <p>this.bottomBoundsHeight: { JSON.stringify(this.bottomBoundsHeight) }</p>

            <div ref={bottomRef} className={styles.bottom}>
              <EmbedBottom ref={instance => { this.EmbedBottom = instance }} selectedPost={this.selectedPost()} />
            </div>

          </div>
        </React.Fragment>
      )

    }

    return (
      <React.Fragment>

        <div className={styles.embed}>

          <Takko />

        </div>

      </React.Fragment>
    )

  }

}
