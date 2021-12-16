import React from 'react'
import { withRouter } from 'react-router-dom'
import _ from 'lodash'
import moment from 'moment'
import USDFormat from '../../../util/USDFormat'
import USDField from '../../../util/USDField'

import styles from '../../css/pool_styles.css'

class PoolInterval extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      amount: (props.interval.fixed ? (props.interval.amount).toString() : ""),
      fixed: props.interval.fixed
    }
  }

  handleClick(e) {
    if (e.target.closest("td")?.dataset.role) { return }
    if (!this.props.unsavedChanges || confirm("are you sure to discard all changes?")) {
      this.props.history.push(
        `/admin/studio/pools/${this.props.poolId}/intervals/${this.props.interval.id}`
      )
    }
  }

  handleInputChange(e) {
    // if (e.target.value == "-") { return } // ignore when there's no number input

    const prev  = this.props.interval
    const value = { amount: e.target.value, fixed: !!e.target.value }
    const amount = isNaN(+e.target.value) ? 0 : +e.target.value
    const prevAmount = isNaN(+prev.amount) ? 0 : +prev.amount

    var change = {
      interval: { ...value, id: prev.id },
      pool: { estimatedAmountChange: 0, poolAmountChange: 0 },
      prev: { amount: prev.amount, fixed: prev.fixed }
    }

    prev.poolAmountChange ||= 0

    if (value.fixed) {
      if (this.state.fixed) {
        change.interval.poolAmountChange = amount - this.state.amount
      } else {
        change.interval.poolAmountChange = prev.poolAmountChange + (amount - prevAmount)
      }
    } else {
      change.pool.estimatedAmountChange = -prev.poolAmountChange
      change.interval.poolAmountChange = 0
    }

    if (prev.fixed) {
      change.pool.fixedAmountChange = amount - prevAmount
      if (!value.fixed) {
        change.pool.estimatedAmountChange += prevAmount
      }
    } else {
      change.pool.fixedAmountChange = amount
      change.pool.estimatedAmountChange = change.interval.poolAmountChange - amount
    }

    change.interval.modified = (this.state.fixed != value.fixed)
    change.interval.modified ||= this.state.fixed && (this.state.amount != amount)

    this.props.updatePool(change)
  }

  render() {
    const interval = this.props.interval

    return (
      <tr
        className={interval.modified ? styles.modified : ""}
        onClick={(e) => this.handleClick(e)}
      >
        <td>{moment(interval.date).format("MM/DD/YYYY")}</td>
        <td>{interval.status}</td>
        <td>
          <USDFormat disabled value={interval.amount} />
        </td>
        <td data-role="action">
          <USDField
            id={interval.id}
            disabled={interval.status != "forecasted"}
            value={interval.fixed ? interval.amount : ""}
            onChange={(e) => this.handleInputChange(e)}
            styles={styles}
            error={this.props.error ? this.props.error[0].amount : null}
          />
          </td>
      </tr>
    )
  }
}
export default withRouter(PoolInterval)
