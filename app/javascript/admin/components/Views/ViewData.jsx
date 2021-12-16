import React from 'react'
import { withRouter } from 'react-router-dom'
import api from '../../../util/api'
import { Link } from 'react-router-dom'
import {
  Row, Col, Navbar, NavbarBrand, NavItem, Button, Table,
  Form, FormGroup, Label, Input
} from 'reactstrap'

import styles from '../../css/pool_styles.css'

class ViewData extends React.Component {
  constructor(props) {
    super(props)

    this.state = { posts: [] }
  }

  componentDidMount() {
    api.post(`/views/data.json`, { date: this.props.date, user_id: this.props.userId })
       .then(response => this.setState(response.data))
  }

  showViewerData(e) {
    this.props.history.push(
      window.location.pathname + `/${e.target.closest('tr').id}`
    )
  }

  render() {
    return (
      <div>
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>creator videos from pool</NavbarBrand>
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
                <span>date from: {this.state.date}</span>
              </div>
            </Col>
          </Row>
        </div>

        <div>
          <div>
            <Table striped hover>
              <thead>
                <tr>
                  <th>video id</th>
                  <th>post/takko</th>
                  <th>video title</th>
                  <th>date published</th>
                  <th>video length</th>
                  <th>total views</th>
                  <th>counted views</th>
                  <th>total unique users</th>
                  <th>total unique sessions</th>
                  <th>total watch time</th>
                  <th>counted watch time</th>
                  <th>total unique watchers</th>
                </tr>
              </thead>
              <tbody>
                { this.state.posts.map((post) =>
                  <tr key={post.id} id={post.id} onClick={(e) => this.showViewerData(e)}>
                    <th>{post.id}</th>
                    <td>{post.post}</td>
                    <td>{post.title}</td>
                    <td>{post.date_published}</td>
                    <td>{post.video_length}</td>
                    <td>{post.total_views}</td>
                    <td>{post.counted_views}</td>
                    <td>{post.total_unique_users}</td>
                    <td>{post.total_unique_sessions}</td>
                    <td>{post.total_watch_time}</td>
                    <td>{post.counted_watch_time}</td>
                    <td>{post.total_unique_watchers}</td>
                  </tr>
                )}
              </tbody>
              <tfoot>
                <tr>
                  <td>total</td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.video_length, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.total_views, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.counted_views, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.total_unique_users, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.total_unique_sessions, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.total_watch_time, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.counted_watch_time, 0) }</td>
                  <td>{ this.state.posts.reduce((p,c) => p + c.total_unique_watchers, 0) }</td>
                </tr>
              </tfoot>
            </Table>
          </div>
        </div>
      </div>
    )
  }
}
export default withRouter(ViewData)
