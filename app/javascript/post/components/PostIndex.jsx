
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Modal } from 'reactstrap'
import sizeMe from 'react-sizeme'
import { Scrollbars } from 'react-custom-scrollbars'
// import { currentUserSession } from '../../currentUser/components/CurrentUser'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'
// import AdSense from 'react-adsense'

import useMeasure from 'react-use-measure'

import { transitions, positions, Provider as AlertProvider } from 'react-alert'
import AlertTemplate from 'react-alert-template-basic'
import { withAlert } from 'react-alert'

import Sidebar from '../../sidebar'

import VideoCover from 'react-video-cover'

import Post from './Post'

import cx from 'classnames'
import styles from '../css/styles.css'
import sharedStyles from '../../shared/css/styles.css'
import embedStyles from '../../embed/css/styles.css'
import imagePath from '../../shared/components/imagePath'

export default class PostIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      modal: false,
      viewPost: {},
      currentUser: currentUser,
      isOpen: false,
      item: {},
      posts: [],
      postsTotal: 0,
      postsTotalPages: 0,
      postsLimit: 10,
      current: 1,
      sidePosts: [],
    }

    this.getRandomInt = this.getRandomInt.bind(this)
    this.getItem = this.getItem.bind(this)
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
    })
  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })

    console.log("updateCurrentUserState done")
  }

  componentDidMount() {
    console.log("class PostIndex componentDidMount")

    // var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getItem()
    // this.getPosts(this.state.current, this.state.postsLimit)
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

  getRandomInt = (max) => {
    return Math.floor(Math.random() * Math.floor(max));
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
    // axios.get(`/feed/p/`+current+`.json`, getHeaders)
    axios.get(`/posts.json?page=`+11+`&limit=`+limit, getHeaders)
      .then(response => {
        const posts = response.data.posts
        const postsTotal = response.data.postsTotal
        const postsTotalPages = response.data.postsTotalPages
        this.setState({ posts: posts, postsTotal: postsTotal, postsTotalPages: postsTotalPages })

        console.log("posts: ")
        console.log(posts)

        // // set first post for styling
        // if (posts.length > 0) {
        //   this.setState({ modal: true, viewPost: posts[0] })
        // }
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

        <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>

        <Container className={styles.post + " h-100"} fluid>

          <img src={ imagePath('takko-emblem.png') } className={styles.logo} />
          <div className={styles.logoBackground} style={{ background: "url('" + imagePath('takko-bg-dark.png') + "')", backgroundSize: 'cover' }}></div>


          <div className={styles.postViewWrap}>
                  
            <Post post={this.state.post} alert={alert} />

          </div>

          <Row className={styles.postRow + " h-100 no-gutters"}>

            <Col
              md={{ size: 6, offset: 3, order: 1 }}
              lg={{ size: 6, offset: 3, order: 1 }}
              xl={{ size: 6, offset: 3, order: 1 }}
              className={cx(styles.content, styles.mainWrap) + " h-100"}>

              <Row className={styles.postRow + " row align-items-center justify-content-md-center"}>

                <Col
                  md={{ size: 11 }}
                  lg={{ size: 11 }}
                  xl={{ size: 10 }}
                  className={styles.postCol}>

                </Col>

              </Row>

            </Col>

            <Col
              md={{ size: 2, offset: 1, order: 2 }}
              lg={{ size: 2, offset: 1, order: 2 }}
              xl={{ size: 2, offset: 1, order: 2 }}>

              <div className={styles.sidebar}>

                <div className={styles.section}>
                  <div className={styles.ad}>
                    <a href="https://apple.co/3w65qgG" target="_blank">
                    <div className={styles.adContent}>
                      <span>Download Takko on the App Store!</span>
                    </div>

                    {/* auto full width responsive ads */}
                      {/*<AdSense.Google
                        client='ca-pub-4575359294698519'
                        slot='1691908319'
                        style={{ display: 'block' }}
                        format='auto'
                        responsive='true'
                        // layoutKey='-gw-1+2a-9x+5c'
                      />*/}

                      <script>
                        {/*(adsbygoogle = window.adsbygoogle || []).push({})*/}
                      </script>
                    </a>
                  </div>
                </div>

                <Scrollbars
                  // style={{height: "auto", minHeight: "75px"}}
                  // renderTrackVertical={props => <div {...props} className={sharedStyles.scrollbarsTrackVertical} style={{display:"none"}} />}
                  renderTrackHorizontal={props => <div {...props} className={sharedStyles.scrollbarsTrackHorizontal} style={{display:"none"}}/>}
                  renderView={props => <div {...props} className={styles.scrollbars} />}
                  universal={true}>

                  <div className={styles.section}>
                    <div className={styles.sideContent}>
                      <h3>Recommended</h3>

                      <div className={styles.sidePostWrap}>

                        <Transition
                          items={this.state.posts}
                          keys={sidePost => sidePost._id}
                          // trail={200}
                          from={{ opacity: 0 }}
                          enter={{ opacity: 1 }}
                          leave={{ opacity: 0, display: 'none' }}
                        >
                          { sidePost => props => (
                            <a href={"/p/"+sidePost.link} style={props} key={sidePost._id} >
                              <Row className={styles.sidePostItem+" justify-content-md-center align-items-center"}>

                                  <Col md="5" className={styles.sidePostCol}>
                                    <div className={styles.postThumb} style={{backgroundImage: "url('" + sidePost.media_thumbnail.url + "')"}}></div>
                                  </Col>

                                  <Col md="7" className={styles.sidePostCol}>
                                    <h4>{sidePost.title}</h4>

                                    { (sidePost.description) && (
                                      <p>{sidePost.description}</p>
                                    )}

                                  </Col>

                              </Row>
                            </a>
                          )}
                        </Transition>
                      </div>
                    </div>
                  </div>
                </Scrollbars>

              </div>

            </Col>

          </Row>
        </Container>


      </React.Fragment>
    )

  }

}
