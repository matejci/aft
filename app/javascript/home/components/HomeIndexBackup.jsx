
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Modal } from 'reactstrap'
import sizeMe from 'react-sizeme'
import Confetti from 'react-confetti'
import { currentUserSession } from '../../currentUser/components/CurrentUser'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css';

import { Player, ControlBar } from 'video-react'
import '!style-loader!css-loader!video-react/dist/video-react.css'
import VideoThumbnail from 'react-video-thumbnail'

import Post from './Post'

import cx from 'classnames'
import styles from '../css/styles.css'

export default class HomeIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      modal: false,
      viewPost: {},
      currentUser: currentUser,
      isOpen: false,
      posts: [],
      postsTotal: 0,
      postsTotalPages: 0,
      postsLimit: 75,
      current: 1,
    }

    this.getPosts = this.getPosts.bind(this)
    this.onChange = this.onChange.bind(this)
    this.updatePostsState = this.updatePostsState.bind(this)
    this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
    this.toggleModal = this.toggleModal.bind(this)
    this.toggle = this.toggle.bind(this)
  }

  toggle() {
    this.setState({
      modal: !this.state.modal
    })
  }

  onChange = (page) => {
    console.log(page)
    this.setState({
      current: page,
    }, this.getPosts(page, this.state.postsLimit))
  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })

    console.log("updateCurrentUserState done")
  }

  componentDidMount() {
    console.log("class HomeIndex componentDidMount")

    var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getPosts(this.state.current, this.state.postsLimit)
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

  toggleModal = (e, post) => {
    e.preventDefault()

    console.log("toggleModal")
    console.log(post)

    this.setState({ viewPost: post })

    this.toggle()
  }

  updatePostsState(data) {
    this.setState({ posts: data })
    console.log("updatePostsState(data) completed")
  }

  getPosts = (current, limit) => {
    // clear posts
    this.setState({ posts: [] })

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get posts
    axios.get(`/posts.json?page=`+current+`&limit=`+limit, getHeaders)
      .then(response => {
        const posts = response.data.posts
        const postsTotal = response.data.postsTotal
        const postsTotalPages = response.data.postsTotalPages
        this.setState({ posts: posts, postsTotal: postsTotal, postsTotalPages: postsTotalPages })

        console.log("posts: ")
        console.log(posts)
    })
  }


  render() {

    // const postsKeys = this.state.posts.length ? this.state.posts.map(post => post._id.$oid) : []

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
                  <DropdownItem href="/create">
                    Create Post
                  </DropdownItem>
                  <DropdownItem>
                    Option 2
                  </DropdownItem>
                  <DropdownItem divider />
                  <DropdownItem color="primary">
                    <a className={styles.navLink} href="/signout">Signout</a>
                  </DropdownItem>
                </DropdownMenu>
              </UncontrolledDropdown>
            </Nav>
          </Collapse>
        </Navbar>

        <Container className={styles.home} fluid>

          <Row className={styles.homeRow + " h-100 no-gutters"}>

            <Col md={{ size: 12, order: 1 }} className={styles.content + " h-100"}>

              <div className={styles.header}>

                Top

              </div>

              <Row className={styles.homeRow}>
                <Transition
                  items={this.state.posts}
                  keys={item => item._id.$oid}
                  // trail={200}
                  from={{ opacity: 0, height: 0 }}
                  enter={{ opacity: 1, height: 400 }}
                  leave={{ opacity: 0, height: 0, display: 'none' }}
                >
                  { item => props => (
                    <Post
                      style={props}
                      post={item}
                      key={item._id.$oid}
                      toggleModal={this.toggleModal}
                      updatePostsState={this.updatePostsState}
                    />
                  )}
                </Transition>
              </Row>

            </Col>

          </Row>
        </Container>



        { !isEmpty(this.state.viewPost) && (

          <Modal
            isOpen={this.state.modal}
            toggle={this.toggle}
            fade={false}
            className={styles.modal}
            contentClassName={styles.modalContent}
            centered>

            <Row className="no-gutters h-100">
              <Col md={6} className="h-100">
                <div className={styles.mediaContent}>

                  <Player
                    ref={instance => { this.player = instance }}
                    className={styles.player}
                    loop={true}
                    controls={false}
                    // aspectRatio={"9:11"}
                    // width={"100%"}
                    // height={"100%"}
                    fluid={false}
                    autoPlay={true}>
                    <source src={this.state.viewPost.media_file.url} />
                    <ControlBar autoHide={false} disableCompletely={true} className="controlBar" />
                  </Player>

                </div>
              </Col>

              <Col md={6}>
                comments here
              </Col>
            </Row>

          </Modal>

        )}



      </React.Fragment>
    )

  }

}
