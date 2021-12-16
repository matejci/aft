import React from 'react'
import api from '../../../util/api'
import moment from 'moment'
import { Redirect, withRouter } from 'react-router-dom'
import { confirmAlert } from 'react-confirm-alert'

import styles from '../../css/styles.css'

class Pool extends React.Component {
  constructor(props) {
    super(props)

    this.handleDelete = this.handleDelete.bind(this)
  }

  formatDate = (date) => {
    return moment(date).format("MM/DD/YYYY")
  }

  handleClick(e) {
    if (e.target.closest("td")?.dataset.role) { return }
    this.props.history.push(`/admin/studio/pools/${this.props.pool.id}`)
  }

  handleDelete() {
    confirmAlert({
      message: `are you sure to delete: ${this.props.pool.name}(${this.props.pool.id})?`,
      buttons: [
        {
          label: "Yes",
          onClick: () => {
            api
              .delete(`/pools/${this.props.pool.id}.json`)
              .then(() => this.props.updatePools())
              .catch(error => {
                console.error(`error: ${error}`)
                confirmAlert({
                  message: `ERROR: ${error.response.data.base}`,
                  buttons: [{ label: "dismiss" }]
                })
              })
          }
        },
        { label: "No" }
      ]
    })
  }

  render() {
    const pool = this.props.pool

    return (
      <tr style={this.props.style} className={styles.item} onClick={(e) => this.handleClick(e)}>
        <th scope="row">{pool.id}</th>
        <td>{pool.name}</td>
        <td>{pool.amount}</td>
        <td>{this.formatDate(pool.start_date)}</td>
        <td>{this.formatDate(pool.end_date)}</td>
        <td>{this.formatDate(pool.created_at)}</td>
        <td data-role="action">
          <a href="#" onClick={() => this.props.toggleEdit(pool)}>edit</a>
          <span> | </span>
          <a href="#" onClick={this.handleDelete}>delete</a>
        </td>
      </tr>
    )
  }

}
export default withRouter(Pool)
