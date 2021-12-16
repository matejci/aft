import React from 'react'
import { withRouter } from 'react-router-dom'
import api from '../../../util/api'
import {
  Row, Col, Navbar, NavbarBrand, NavItem, Button, Table,
  Form, FormGroup, Label, Input
} from 'reactstrap'

import styles from '../../css/pool_styles.css'

class ViewPostData extends React.Component {
  constructor(props) {
    super(props)

    this.state = { viewers: [] }
  }

  componentDidMount() {
    api
      .post(
        `/views/data.json`,
        {
          date: this.props.date,
          user_id: this.props.userId,
          post_id: this.props.postId
        }
      ).then(response => this.setState(response.data))
  }

  showViewerEvents(e) {
    this.props.history.push(
      window.location.pathname + `/viewer/${e.target.closest('tr').id}`
    )
  }

  render() {
    return (
      <div>
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>viewer data</NavbarBrand>
            <NavItem>
              <Button color="primary" onClick={() => this.props.history.goBack()}>back</Button>
            </NavItem>
          </Navbar>
          <Row>
            <Col>
              <div>
                <span>full name: {this.state.full_name}</span>
              </div>
              <div>
                <span>username: {this.state.username}</span>
              </div>
              <div>
                <span>data from: {this.state.viewed_date}</span>
              </div>
              <div>
                <span>video title: {this.state.title}</span>
              </div>
              <div>
                <span>video type: {this.state.type}</span>
              </div>
              <div>
                <span>date published: {this.state.date_published}</span>
              </div>
            </Col>
          </Row>
        </div>

        <div>
          <div>
            <Table striped hover>
              <thead>
                <tr>
                  <th>user id</th>
                  <th>sessions</th>
                  <th>username</th>
                  <th>full name</th>
                  <th>viewed date</th>
                  <th>views</th>
                  <th>counted views</th>
                  <th>total watch time</th>
                  <th>counted watch time</th>
                </tr>
              </thead>
              <tbody>
                { this.state.viewers.map((viewer) =>
                  <tr key={viewer.id} id={viewer.id} onClick={(e) => this.showViewerEvents(e)}>
                    <th>{viewer.id}</th>
                    <td>{viewer.view_trackings}</td>
                    <td>{viewer.username}</td>
                    <td>{viewer.full_name}</td>
                    <td>{this.state.viewed_date}</td>
                    <td>{viewer.total_views}</td>
                    <td>{viewer.counted_views}</td>
                    <td>{viewer.total_watch_time}</td>
                    <td>{viewer.counted_watch_time}</td>
                  </tr>
                )}
              </tbody>
              <tfoot>
                <tr>
                  <td colSpan={5}>total</td>
                  <td>{ this.state.viewers.reduce((p,c) => p + c.total_views, 0) }</td>
                  <td>{ this.state.viewers.reduce((p,c) => p + c.counted_views, 0) }</td>
                  <td>{ this.state.viewers.reduce((p,c) => p + c.total_watch_time, 0) }</td>
                  <td>{ this.state.viewers.reduce((p,c) => p + c.counted_watch_time, 0) }</td>
                </tr>
              </tfoot>
            </Table>
          </div>
        </div>
      </div>
    )
  }
}
export default withRouter(ViewPostData)
