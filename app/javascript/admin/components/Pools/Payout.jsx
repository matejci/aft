import React from 'react'
import { withRouter } from 'react-router-dom'
import USDFormat from '../../../util/USDFormat'

class Payout extends React.Component {
  constructor(props) {
    super(props)
  }

  handleClick(e) {
    let payout = this.props.payout
    this.props.history.push(
      `/admin/studio/pools/views/${payout.date}/${payout.user_id}`
    )
  }

  render() {
    const po = this.props.payout

    return (
      <tr
        onClick={(e) => this.handleClick(e)}
        key={po.id}
      >
        <th>{po.id}</th>
        <th>{po.status}</th>
        <td>{po.user_username}</td>
        <td>{po.user_full_name}</td>
        <td>{po.total_views}</td>
        <td>{po.counted_views}</td>
        <td>{po.percent}</td>
        <td>{po.watch_time}</td>
        <td><USDFormat disabled value={po.amount} /></td>
        <td><USDFormat disabled value={po.paying_amount} /></td>
        <td><USDFormat disabled value={po.remaining_amount} /></td>
      </tr>
    )
  }
}
export default withRouter(Payout)
