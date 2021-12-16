
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import _ from 'lodash'
import api from '../util/api'
import { Transition } from 'react-spring/renderprops'
import { Container, Row, Col, Button, Form, FormGroup, Label, Input, FormText, Collapse, Navbar, NavbarToggler, NavbarBrand, Nav, NavItem, NavLink, UncontrolledDropdown, DropdownToggle, DropdownMenu, DropdownItem, Modal } from 'reactstrap'
import sizeMe from 'react-sizeme'
import { Scrollbars } from 'react-custom-scrollbars'
import { currentUserSession } from '../currentUser/components/CurrentUser'
import Pagination from 'rc-pagination'
import '!style-loader!css-loader!rc-pagination/assets/index.css'

import Sidebar from './components/Sidebar'
import DashboardIndex from './components/Dashboard/Index'
import PoolsIndex from './components/Pools/Index'
import SubscribersIndex from './components/Subscribers/Index'
import InvitationsIndex from './components/Invitations/Index'
import UsernamesIndex from './components/Usernames/Index'
import SupportedVersionsIndex from './components/SupportedVersions'

import cx from 'classnames'
import styles from './css/styles.css'
import sharedStyles from "../shared/css/styles.css"

class Admin extends React.Component {

	constructor(props) {
    super(props)

		var selected = window.location.pathname
										.match(/^\/admin\/studio\/(pools)/)

    this.state = {
      errors: {},
      currentUser: currentUser,
      page: (selected ? _.camelCase(selected[1]) : "dashboard")
    }

    this.updatePage = this.updatePage.bind(this)
    this.updateCurrentUserState = this.updateCurrentUserState.bind(this)
  }

  componentDidMount() {
    console.log("class Admin componentDidMount()")
    var currentUserUpdate = currentUserSession(this.updateCurrentUserState)
  }

  componentWillUnmount() {

  }

  updateCurrentUserState(currentUserState) {
    this.setState({
      currentUser: currentUserState
    })
  }

  updatePage(e, page) {
    e.preventDefault()
    this.setState({ page: page })
		window.history.pushState(null, "", `/admin/studio/${page}`)
  }

	components = { pools: PoolsIndex }

  render() {

		var RoutedIndex
		if (["pools"].includes(this.state.page)) {
			RoutedIndex = this.components[this.state.page]
		}

    return (
      <React.Fragment>

        <Container className={styles.admin + " h-100"} fluid>

          <Row className={styles.adminRow + " h-100 no-gutters"}>

            <Sidebar md="2" active={this.state.page} updatePage={this.updatePage} currentUser={this.state.currentUser} />

            <Col md={{ size: 10, order: 1 }} className={cx(styles.content, sharedStyles.mainWrap) + " h-100"}>
							{ RoutedIndex && <RoutedIndex /> }
							{ !RoutedIndex &&
								<Scrollbars
									// style={{height: "700px"}}
									// renderTrackVertical={props => <div {...props} className={sharedStyles.scrollbarsTrackVertical} />}
									renderTrackHorizontal={props => <div {...props} className={sharedStyles.scrollbarsTrackHorizontal} style={{display:"none"}}/>}
									renderView={props => <div {...props} className={sharedStyles.scrollbars} />}
									universal={true}>

									<React.Fragment>

										{ (this.state.page == "dashboard") && (
											<DashboardIndex currentUser={this.state.currentUser} />
										)}


										{ (this.state.page == "subscribers") && (
											<SubscribersIndex currentUser={this.state.currentUser} />
										)}

										{ (this.state.page == "invitations") && (
											<InvitationsIndex currentUser={this.state.currentUser} />
										)}

										{ (this.state.page == "usernames") && (
											<UsernamesIndex currentUser={this.state.currentUser} />
										)}

										{ (this.state.page == "supported_versions") && (
											<SupportedVersionsIndex currentUser={this.state.currentUser} />
										)}

									</React.Fragment>

								</Scrollbars>
							}
            </Col>
          </Row>
        </Container>


      </React.Fragment>
    )
  }
}


ReactDOM.render(
  <Admin />,
  document.body.appendChild(document.getElementById('content'))
)
