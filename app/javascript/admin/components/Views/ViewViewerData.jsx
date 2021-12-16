import React from 'react'
import { withRouter } from 'react-router-dom'
import api from '../../../util/api'
import {
  Row, Col, Navbar, NavbarBrand, NavItem, Button, Table,
  Form, FormGroup, Label, Input
} from 'reactstrap'

import styles from '../../css/pool_styles.css'

class ViewViewerData extends React.Component {
  constructor(props) {
    super(props)

    this.state = { views: [], view_trackings: [] }
  }

  componentDidMount() {
    api
      .post(
        `/views/events_data.json`,
        {
          date: this.props.date,
          user_id: this.props.userId,
          post_id: this.props.postId,
          viewer_id: this.props.viewerId
        }
      ).then(response => this.setState(response.data))
  }

  showViewerEvents(e) {
    this.props.history.push(
      window.location.pathname + `/${e.target.closest('tr').id}`
    )
  }

  render() {
    return (
      <div>
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>viewer sessions data</NavbarBrand>
            <NavItem>
              <Button color="primary" onClick={() => this.props.history.goBack()}>back</Button>
            </NavItem>
          </Navbar>
          <Row>
            <Col>
              <div>
                <span>date viewed: {this.state.viewed_date}</span>
              </div>
              <div>
                <span>video: {this.state.title} ({this.state.type})</span>
              </div>
              <div>
                <span>viewer username: {this.state.username}</span>
              </div>
              <div>
                <span>viewer full name: {this.state.full_name}</span>
              </div>
            </Col>
          </Row>
        </div>

        <div>
          <div>
            <Table striped hover>
              <thead>
                <tr>
                  <th>view id</th>
                  <th>view tracking id</th>
                  <th>start time</th>
                  <th>end time</th>
                  <th>counted</th>
                  <th>watch time</th>
                  <th>watch time counted</th>
                </tr>
              </thead>
              <tbody>
                { this.state.views.map((v) =>
                  <tr key={v.id}>
                    <th>{v.id}</th>
                    <td>{v.view_tracking_id}</td>
                    <td>{v.start_time}</td>
                    <td>{v.end_time}</td>
                    <td>{`${v.counted}`}</td>
                    <td>{v.watch_time}</td>
                    <td>{`${v.watch_time_counted}`}</td>
                  </tr>
                )}
              </tbody>
            </Table>
            <h4>view trackings</h4>
            <Table striped hover>
              <thead>
                <tr>
                  <th>view tracking id</th>
                  <th>user agent</th>
                  <th>ip address</th>
                  <th>events</th>
                  <th># of pauses</th>
                </tr>
              </thead>
              <tbody>
                { this.state.view_trackings.map((vt) =>
                  <tr key={vt.id}>
                    <th>{vt.id}</th>
                    <td>{vt.user_agent}</td>
                    <td>{vt.ip_address}</td>
                    <td>
                      <ul>
                        { vt.events.map((e) => <li>{e.action}: {e.timestamp}</li>) }
                      </ul>
                    </td>
                    <td>{vt.paused_events}</td>
                  </tr>
                )}
              </tbody>
            </Table>
          </div>
        </div>
      </div>
    )
  }
}
export default withRouter(ViewViewerData)
