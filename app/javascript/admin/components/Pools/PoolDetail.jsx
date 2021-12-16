import React from 'react'
import moment from 'moment'
import api from '../../../util/api'
import { Link } from 'react-router-dom'
import { confirmAlert } from 'react-confirm-alert'
import {
  Row, Col, Navbar, NavbarBrand, NavItem, Button, Table,
  Form, FormGroup, Label, Input
} from 'reactstrap'
import USDFormat from '../../../util/USDFormat'
import USDField from '../../../util/USDField'
import CustomTextField from '../../../util/CustomTextField'
import PoolInterval from './PoolInterval'

import styles from '../../css/pool_styles.css'

const initialState = {
  amount: 0,
  daily_amount: 0,
  intervals: [],
  initialData: {},
  modified: {},
  errors: {}
}

export default class PoolDetail extends React.Component {
  constructor(props) {
    super(props)

    this.state = initialState
    this.discardChanges = this.discardChanges.bind(this)
    this.updatePool = this.updatePool.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    this.fetchPool()
  }

  discardChanges() {
    confirmAlert({
      message: "are you sure to discard all changes?",
      buttons: [
        {
          label: "Yes",
          onClick: () => this.fetchPool()
        },
        { label: "No" }
      ]
    })
  }

  estimated(el) {
    return (el.status == "forecasted") && !el.fixed
  }

  estimatedRows(rows=this.state.intervals) {
    return rows.filter((el) => this.estimated(el))
  }

  fetchPool() {
    api
      .get(`/pools/${this.props.poolId}.json`)
      .then(response => this.setPool(response.data))
  }

  handleAmountChange(e) {
    if (+e.target.value == this.state.amount) { return } // ignore initial render

    if (e.target.value) {
      var amount, dailyAmount, estimatedAmount, lockedAmount
      amount = +e.target.value

      lockedAmount = _.reduce(
        _.pick(
          this.state, "fixed_amount", "processed_amount", "paid_amount", "remaining_amount"
        ),
        (sum, value, _key) => sum + +value
      )

      estimatedAmount = (amount - lockedAmount)
      dailyAmount = estimatedAmount / this.estimatedRows().length

      this.setStateChanges({
        amount: amount,
        estimated_amount: estimatedAmount,
        daily_amount: dailyAmount,
        intervals: this.setDailyAmount(dailyAmount)
      })
    } else {
      this.setStateChanges({ amount: e.target.value })
    }
  }

  handleDailyAmountChange(e) {
    if (+e.target.value == this.state.daily_amount) { return } // ignore initial render

    var dailyAmount, intervals
    dailyAmount = isNaN(+e.target.value) ? 0 : +e.target.value

    if (dailyAmount == this.state.daily_amount) { return }

    intervals = this.setDailyAmount(dailyAmount)

    this.setStateChanges({
      amount: this.sumAmount(intervals),
      estimated_amount: dailyAmount * this.estimatedRows().length,
      daily_amount: e.target.value,
      intervals: intervals
    })
  }

  handleSubmit() {
    confirmAlert({
      title: "save changes",
      message: "are you sure to make these permanent?",
      buttons: [
        {
          label: "Yes",
          onClick: () => {
            const poolData = {
              ..._.pick(this.state, "amount", "daily_amount", "estimated_amount", "fixed_amount"),
              intervals_attributes: this.state.intervals.map((interval) => _.pick(interval, "id", "amount", "fixed"))
            }
            console.log(poolData)
            api
              .patch(`/pools/${this.state.id}.json`, { pool: poolData })
              .then(response => this.setPool(response.data))
              .catch((error)=> {
                if (error.response) {
                  this.setState({ errors: error.response.data })
                }
              })
          }
        },
        { label: "No" }
      ]
    })
  }

  setDailyAmount(amount, rows=this.state.intervals) {
    return (
      [...rows].map((interval) => {
        if (this.estimated(interval)) { return { ...interval, amount: amount} }
        return interval
      })
    )
  }

  setPool(data) {
    this.setState({ ...initialState, ...data, initialData: _.cloneDeep(data) })
  }

  setStateChanges(changes) {
    var modified = Object.assign({}, this.state.modified)
    // react saga, reducer
    Object.entries(changes).forEach(([k,v]) => {
      if ((k == "intervals" && v.some((el) => el.modified)) || (this.state.initialData[k] != v)) {
        modified[k] = true
      } else {
        delete modified[k]
      }
    })

    this.setState({ ...changes, modified: modified })
  }

  sumAmount(rows) {
    return _.reduce(rows, (r, {amount}) => r + +amount, 0)
  }

  updatePool(change) {
    var pool = {}
    var intervals = [...this.state.intervals].map((el) => {
      return ((el.id == change.interval.id) ? { ...el, ...change.interval } : el)
    })

    pool.fixed_amount = this.state.fixed_amount + change.pool.fixedAmountChange
    pool.amount = this.state.amount + change.pool.fixedAmountChange

    if (!_.isUndefined(change.pool.estimatedAmountChange)) {
      pool.amount += change.pool.estimatedAmountChange
      pool.estimated_amount = this.state.estimated_amount + change.pool.estimatedAmountChange
      pool.daily_amount = pool.estimated_amount / this.estimatedRows(intervals).length
      intervals = this.setDailyAmount(pool.daily_amount, intervals)
    }

    this.setStateChanges({ ...pool, intervals: intervals })
  }

  render() {
    var intervals = (
      this.state.intervals.map((item) => {
        return(
          <PoolInterval
            key={item.id}
            interval={item}
            unsavedChanges={!_.isEmpty(this.state.modified)}
            updatePool={this.updatePool}
            poolId={this.props.poolId}
            error={this.state.errors[item.id]}
          />
        )
      })
    )

    return(
      <div className={styles.pool_detail}>
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>{this.state.name}</NavbarBrand>
            <NavItem>
              { !_.isEmpty(this.state.modified) &&
                <React.Fragment>
                  <Button color="primary" onClick={this.handleSubmit}>save</Button>
                  <Button color="secondary" onClick={this.discardChanges}>x</Button>
                </React.Fragment>
              }
              { _.isEmpty(this.state.modified) &&
                <Button color="info">
                  <Link to="/admin/studio/pools">back to pools</Link>
                </Button>
              }
            </NavItem>
          </Navbar>
          <Row>
            <Col className={this.state.modified["fixed_amount"] && styles.modified}>
              <ul className={styles.amount_details}>
                <li>{this.state.dates}</li>
                <li className={this.state.modified["estimated_amount"] && styles.yellow_text}>
                  <span>estimated: </span>
                  <USDFormat disabled value={this.state.estimated_amount} />
                </li>
                <li className={this.state.modified["fixed_amount"] && styles.yellow_text}>
                  <span>fixed: </span>
                  <USDFormat disabled value={this.state.fixed_amount} />
                </li>
                <li>
                  <span>processed: </span>
                  <USDFormat disabled value={this.state.processed_amount} />
                </li>
                <li>
                  <span>paid: </span>
                  <USDFormat disabled value={this.state.paid_amount} />
                </li>
                <li>
                  <span>remaining: </span>
                  <USDFormat disabled value={this.state.remaining_amount} />
                </li>
              </ul>
            </Col>
            <Col>
              <div className={this.state.modified["amount"] && styles.yellow_text}>
                <Label for="amount">Amount</Label>
                <USDField
                  name="amount"
                  id="amount"
                  value={this.state.amount}
                  styles={styles}
                  error={this.state.errors.amount}
                  onChange={(e) => this.handleAmountChange(e)} />
              </div>
            </Col>
            <Col>
              <FormGroup className={this.state.modified["daily_amount"] && styles.yellow_text}>
                <Label for="daily_amount">Daily Amount</Label>
                <USDField
                  name="daily_amount"
                  id="daily_amount"
                  value={this.state.daily_amount}
                  styles={styles}
                  error={this.state.errors.daily_amount}
                  onChange={(e) => this.handleDailyAmountChange(e)} />
              </FormGroup>
            </Col>
          </Row>
        </div>

        <div className={styles.main_body}>
          <div>
            <Table>
              <thead>
                <tr>
                  <th>date</th>
                  <th>status</th>
                  <th>amount</th>
                  <th>fixed amount</th>
                </tr>
              </thead>
            </Table>
          </div>
          <div>
            <Table>
              <tbody>
                { intervals }
              </tbody>
            </Table>
          </div>
        </div>
      </div>
    )
  }
}
