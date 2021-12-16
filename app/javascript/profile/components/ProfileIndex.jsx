
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
// import mergeRefs from 'react-merge-refs'

import NumberFormat from 'react-number-format'
import StepWizard from 'react-step-wizard'
// import Post from '../../post/components/Post'
import ProfileSection from './ProfileSection'


import cx from 'classnames'
import styles from '../css/styles.css'
import sharedStyles from '../../shared/css/styles.css'
import imagePath from '../../shared/components/imagePath'

import EnvClient from '../../util/env'
import mixpanel from 'mixpanel-browser'

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

function isValidHttpUrl(string) {
  let url
  
  try {
    url = new URL(string)
  } catch (_) {
    return false; 
  }

  return url.protocol === "http:" || url.protocol === "https:"
}

export default class ProfileIndex extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      profile: {}
    }
    this.bottomBoundsHeight = 0
    this.activeSection = location.hash == '' ? 'posts' : location.hash.substr(1)

    this.clientHeight = 0
    this.scrollDirection = ''
    this.scrollLocation = 0
    this.scrollEnd = false
    this.scrollOffset = 0

    this.profileScroll = React.createRef()

    this.getProfile = this.getProfile.bind(this)
    this.onSectionChange = this.onSectionChange.bind(this)
    this.toggleSection = this.toggleSection.bind(this)
    this.onScroll = this.onScroll.bind(this)
  }

  componentDidMount() {
    console.log("class ProfileIndex componentDidMount")

    // var currentUserUpdate = currentUserSession(this.updateCurrentUserState)

    this.getProfile()

    if (EnvClient.mixpanelTracking()) {
      mixpanel.init(EnvClient.mixpanelToken)
      mixpanel.track('Profile', {
        'profile': `${username}`,
      })
    }
  }

  componentWillUnmount() {

  }

  onScroll = (event) => {
    const target = event.target
    const offset = this.scrollOffset

    const scrollY = window.scrollY // don't get confused by what's scrolling - It's not the window
    const scrollTop = this.profileScroll.current.scrollTop

    const previousScrollLocation = this.scrollLocation
    const currentScrollLocation = target.scrollHeight - target.scrollTop
    if (previousScrollLocation < currentScrollLocation) {
      this.scrollDirection = 'up'
      this.scrollLocation = currentScrollLocation
    } else if (previousScrollLocation > currentScrollLocation) {
      this.scrollDirection = 'down'
      this.scrollLocation = currentScrollLocation
    } else {
      this.scrollDirection = ''
      this.scrollLocation = currentScrollLocation
    }

    // console.log(`this.clientHeight: ${this.clientHeight} | target.clientHeight: ${target.clientHeight}`)
    if (this.clientHeight !== target.clientHeight) {
      // reset scroll end
      this.scrollEnd = false
    }
    this.clientHeight = target.clientHeight

    if( (target.scrollHeight - target.scrollTop) <= (target.clientHeight + offset) && this.scrollDirection == 'down' ) {
      if (!this.scrollEnd) {
        console.log('REACHED THE END')
        this.paginate()
        this.scrollEnd = true
      }
    }
  }

  paginate = () => {
    // console.log('paginate active section')

    if (this.activeSection == 'posts') {
      this.ProfilePosts.onPaginate()
    } else if (this.activeSection == 'takkos') {
      this.ProfileTakkos.onPaginate()
    }
  }

  toggleSection(e, section) {
    e.preventDefault()
    this.Sections.goToStep(section)
  }

  handleInputChange(event) {
    const target = event.target
    const value = target.value
    const name = target.name

    this.setState({
      [name]: value
    })
  }

  getProfile = () => {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get profile
    axios.get(`/profiles/`+username+`/user.json`, getHeaders)
      .then(response => {
        const profile = response.data
        this.setState({ profile: profile })



        // console.log("getProfile: ")
        // console.log(profile)
    })
  }

  onSectionChange = (stats) => {
    // console.log(stats)

    if (stats.activeStep == 1) {
      this.activeSection = 'posts'
    } else if (stats.activeStep == 2) {
      this.activeSection = 'takkos'
    }

    // reset scrollEnd
    this.scrollEnd = false
  }

  render() {

    const profile = this.state.profile

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

    const Header = () => {
      const [ref, bounds] = useMeasure()

      const width = Math.round(bounds.width)
      const height = Math.round(bounds.height)

      var headerStyle = {}
      if (profile.background_image_url) {
        headerStyle = {
          backgroundImage: `url('${profile.background_image_url}`
        }
      } else {
        headerStyle = {}
      }

      return (
        <React.Fragment>
          <div ref={ref} className={styles.header}>
            <div className={profile.background_image_url ? cx(styles.headerBackground, styles.blur) : styles.headerBackground} style={headerStyle}></div>
          </div>
        </React.Fragment>
      )

    }

    const ProfileCard = () => {
      const [ref, bounds] = useMeasure()
      const [cardRef, cardBounds] = useMeasure()
      const [displayRef, displayBounds] = useMeasure()

      const width = Math.round(bounds.width)
      const height = Math.round(bounds.height)

      const cardWidth = Math.round(cardBounds.width)
      const border = cardWidth/65

      const displayHeight = Math.round(displayBounds.height)
      const badgeWidth = displayHeight*0.8

      const headerHeight = window.innerHeight*0.3
      const offset = ((height/2) <= (headerHeight/2)) ? height/2 : headerHeight/2

      return (
        <React.Fragment>
          <div ref={ref} className={styles.profileCard} style={{ marginTop: -(offset) }}>

            <Container className={styles.profileContainer}>
              <Row className={styles.profileRow + " no-gutters justify-content-md-center align-items-center"}>
                <Col md={{ size: 7 }}>
                  <div ref={cardRef} className={styles.profileCardBox}>

                    <Row className={styles.profileRow + " no-gutters justify-content-md-center align-items-center"}>
                      <Col className={styles.profileCol} xs={{ size: 5 }} sm={{ size: 4 }} md={{ size: 5 }} lg={{ size: 4 }} xl={{ size: 3 }}>
                        <div className={cx(styles.profileImage, styles.aspectRatio)} style={{ backgroundImage: `url('${profile.profile_thumb_url}`, border: `${border}px solid rgba(255,255,255,1.0)`, width: `100%`, paddingTop: `calc(100% - ${border*2}px)` }}></div>
                      </Col>
                    </Row>

                    <div className={styles.profileCenterInfo}>
                      <div className={styles.displayName}>
                        <h1 ref={displayRef}>{ profile.display_name }</h1>

                        {profile.verified && (
                          <span className={styles.verifiedBadge} style={{ width: badgeWidth, height: badgeWidth }}><img src={ imagePath('verified-badge.png') } /></span>
                        )}
                      </div>

                      <h2>@{ profile.username }</h2>

                      <p className={styles.bio}>
                        { !isEmpty(profile.bio) && profile.bio.split('\n').map((line, i) => (
                            <span key={i} className={styles.profileBioLines}>
                              {line}
                            </span>
                        )) }
                      </p>

                      <a className={styles.website} href={isValidHttpUrl(profile.website) ? profile.website : `http://${profile.website}`} target='_blank'>{ profile.website }</a>
                    </div>

                    <div className={styles.profileMetricSection}>
                      <Row className={styles.profileRow + " no-gutters justify-content-md-center align-items-center"}>
                        <Col className={styles.profileCol} xs={{ size: 6 }} sm={{ size: 3 }}>
                          <div className={styles.profileMetrics}>
                            <div className={styles.metric}>
                              <NumberFormat value={profile.followers_count} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
                            </div>
                            <label className={styles.metricLabel}>{profile.followers_count == 1 ? 'Follower' : 'Followers'}</label>
                          </div>
                        </Col>

                        <Col className={styles.profileCol} xs={{ size: 6 }} sm={{ size: 3 }}>
                          <div className={styles.profileMetrics}>
                            <div className={styles.metric}>
                              <NumberFormat value={profile.followees_count} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
                            </div>
                            <label className={styles.metricLabel}>Following</label>
                          </div>
                        </Col>

                        <Col className={styles.profileCol} xs={{ size: 6 }} sm={{ size: 3 }}>
                          <div className={styles.profileMetrics}>
                            <div className={styles.metric}>
                              <NumberFormat value={profile.posts_count} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
                            </div>
                            <label className={styles.metricLabel}>{profile.posts_count == 1 ? 'Post' : 'Posts'}</label>
                          </div>
                        </Col>

                        <Col className={styles.profileCol} xs={{ size: 6 }} sm={{ size: 3 }}>
                          <div className={styles.profileMetrics}>
                            <div className={styles.metric}>
                              <NumberFormat value={profile.takkos_count} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
                            </div>
                            <label className={styles.metricLabel}>{profile.takkos_count == 1 ? 'Takko' : 'Takkos'}</label>
                          </div>
                        </Col>
                      </Row>
                    </div>

                  </div>
                </Col>
              </Row>
            </Container>

          </div>
        </React.Fragment>
      )

    }

    const ProfilePosts = (props) => {
      return (
        <div className={styles.profileSections}>

          <ProfileSection section={'posts'} ref={instance => { this.ProfilePosts = instance }} isActive={props.isActive} />

        </div>
      )
    }

    const ProfileTakkos = (props) => {
      return (
        <div className={styles.profileSections}>
          
          <ProfileSection section={'takkos'} ref={instance => { this.ProfileTakkos = instance }} isActive={props.isActive} />

        </div>
      )
    }

    const ProfileContent = () => {
      const [ref, bounds] = useMeasure()

      const width = Math.round(bounds.width)
      const height = Math.round(bounds.height)

      return (
        <React.Fragment>
          <div ref={ref} className={styles.profileContent}>

            <div className={styles.sectionNavigation}>
              <div className={styles.sectionNavigationLinks}><a href="#" onClick={(e) => this.toggleSection(e, 1)}>Posts</a></div>
              <div className={styles.sectionNavigationLinks}><a href="#" onClick={(e) => this.toggleSection(e, 2)}>Takkos</a></div>
            </div>

            <StepWizard
              ref={instance => { this.Sections = instance }}
              className={styles.sections}
              // initialStep={1}
              // isLazyMount={true}
              onStepChange={ (stats) => this.onSectionChange(stats) }
              isHashEnabled={true}>

              <ProfilePosts hashKey={'posts'} />

              <ProfileTakkos hashKey={'takkos'} />

            </StepWizard>

          </div>
        </React.Fragment>
      )

    }

    const Profile = () => {
      const [ref, bounds] = useMeasure()

      const width = Math.round(bounds.width)
      const height = Math.round(bounds.height)

      return (
        <React.Fragment>
          <div ref={ref} className={styles.takkoShell}>

            <ProfileCard />

            <ProfileContent />

          </div>
        </React.Fragment>
      )

    }

    return (
      <React.Fragment>
        <div className={styles.profile + " h-100"}>

          {isEmpty(this.state.profile) ? (
            <Container className={styles.profileContainer + " h-100"}>
              <React.Fragment>
                <Loading />
              </React.Fragment>
            </Container>
          ) : (
            <div ref={this.profileScroll} className={styles.profileScroll} onScroll={(e) => this.onScroll(e)}>
              <Header />

              <Container className={styles.profileContainer}>
                <Row className={styles.profileRow + " no-gutters"}>

                  <Col md={{ size: 12 }}>

                    <Profile />

                  </Col>

                </Row>
              </Container>
            </div>
          )}
        </div>
      </React.Fragment>
    )

  }

}
