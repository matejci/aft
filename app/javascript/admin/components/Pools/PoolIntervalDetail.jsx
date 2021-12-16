import React from 'react'
import { Link } from 'react-router-dom'
import { confirmAlert } from 'react-confirm-alert'
import moment from 'moment'
import api from '../../../util/api'
import {
  Row, Col, Navbar, NavbarBrand, NavItem, Button, Table,
  Form, FormGroup, Label, Input
} from 'reactstrap'
import USDFormat from '../../../util/USDFormat'
import CustomTextField from '../../../util/CustomTextField'
import USDField from '../../../util/USDField'
import styles from '../../css/pool_styles.css'
import PoolInterval from './PoolInterval'
import Payout from './Payout'

const initialState = {
  total_watch_time: 0,
  watch_time_rate: 0,
  amountChange: 0,
  pool: {},
  initialData: {},
  modified: {},
  errors: {}
}

export default class PoolIntervalDetail extends React.Component {
  constructor(props) {
    super(props)

    this.state = initialState
    this.discardChanges = this.discardChanges.bind(this)
    this.handleProcess = this.handleProcess.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    this.fetchPoolInterval()
  }

  fetchPoolInterval() {
    api
      .get(`/pool_intervals/${this.props.intervalId}.json`)
      .then(response => this.setPoolInterval(response.data))
  }

  setPoolInterval(data) {
    this.setState({
      ...initialState,
      ...data,
      poolAmount: data.pool.amount,
      initialData: _.cloneDeep(data),
      daysToValidate: this.daysToValidate(data.validate_by)
    })
  }

  daysToValidate(date) {
    return moment.duration(moment(date).diff(moment().startOf("day"))).asDays()
  }

  payoutsRateChange(newRate) {
    return(
      [...this.state.payouts].map((payout) => {
        var payoutAmount, payingAmount
        payoutAmount = payout.watch_time * newRate
        payingAmount = Math.floor(payoutAmount * 100) / 100

        return({
          ...payout,
          amount: payoutAmount,
          paying_amount: payingAmount,
          remaining_amount: payoutAmount - payingAmount
        })
      })
    )
  }

  payoutsSum(field) {
    var precision, sum

    precision = 0
    sum = (
      this.state.payouts.reduce((p,c) => {
        precision = Math.max(precision, this.precisionCount(c[field]))
        return (parseFloat(p) + c[field]).toFixed(precision)
      }, 0)
    )

    // NOTE: rounded to 6 decimal places
    return Math.round(sum * 100000) / 100000
  }

  precisionCount(n) {
    return (n % 1 == 0 ) ? 0 : n.toString().split(".")[1].length
  }

  poolAmountChange(newAmount) {
    const amountChange = newAmount - this.state.initialData.amount

    return({
      amountChange: amountChange,
      poolAmount: this.state.initialData.pool.amount + amountChange
    })
  }

  handleAmountChange(e) {
    if (this.state.amount.toString() == e.target.value) { return }

    var amount, change
    amount = isNaN(+e.target.value) ? 0 : +e.target.value
    change = { ...this.poolAmountChange(amount), amount: e.target.value }

    if (this.state.total_watch_time) {
      const watchTimeRate = amount / this.state.total_watch_time

      change = {
        ...change,
        watch_time_rate: watchTimeRate,
        payouts: this.payoutsRateChange(watchTimeRate)
      }
    }

    this.setStateChanges(change)
  }

  handleRateChange(e) {
    if (
      this.state.watch_time_rate == null
      || (this.state.watch_time_rate.toString() == e.target.value)
    ) { return }

    const watchTimeRate = isNaN(+e.target.value) ? 0 : +e.target.value
    const amount = this.state.total_watch_time * watchTimeRate

    this.setStateChanges({
      ...this.poolAmountChange(amount),
      amount: amount,
      watch_time_rate: e.target.value,
      payouts: this.payoutsRateChange(watchTimeRate)
    })
  }

  discardChanges() {
    confirmAlert({
      message: "are you sure to discard all changes?",
      buttons: [
        {
          label: "Yes",
          onClick: () => this.fetchPoolInterval()
        },
        { label: "No" }
      ]
    })
  }

  handleProcess() {
    confirmAlert({
      customUI: ({ onClose }) => {
        return (
          <div>
            <h4>ready to process?</h4>
            <p>warning: this action is irreversible</p>
            <Row style={{ float: "right" }}>
              <Button color="secondary" onClick={onClose}>no</Button>
              <Button
                color="primary"
                onClick={() => {
                  api
                  .patch(`/pool_intervals/${this.state.id}/process_interval.json`)
                  .then(response => this.setPoolInterval(response.data))
                  .catch((error)=> {
                    if (error.response) {
                      console.log(`JSON.parse error=> ${JSON.stringify(error.response.data)}`)
                      this.setState({ errors: error.response.data })
                    }
                  })
                  onClose()
                }}
              >
                Yes
              </Button>
            </Row>
          </div>
        );
      }
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
            const intervalData = {
              ..._.pick(this.state, "amount", "watch_time_rate"),
              fixed: this.state.fixed || !!this.state.modified["amount"],
              payouts_attributes: this.state.payouts.map((po) => _.pick(po, "id", "amount"))
            }

            api
              .patch(`/pool_intervals/${this.state.id}.json`, { pool_interval: intervalData })
              .then(response => this.setPoolInterval(response.data))
              .catch((error)=> {
                if (error.response) {
                  console.log(`JSON.parse error=> ${JSON.stringify(error.response.data)}`)
                  this.setState({ errors: error.response.data })
                }
              })
          }
        },
        { label: "No" }
      ]
    })
  }

  setStateChanges = (changes) => {
    var modified = Object.assign({}, this.state.modified)

    Object.entries(changes).forEach(([k,v]) => {
      if (this.state.initialData[k] != v) {
        modified[k] = true
      } else {
        delete modified[k]
      }
    })

    this.setState({ ...changes, modified: modified })
  }

  render() {
    var amountChange

    if (this.state.amountChange) {
      amountChange = (
        <span className={styles.yellow_text}>
          ({this.state.amountChange})
        </span>
      )
    }

    return(
      <div className={styles.interval_detail}>
        { this.state.errors.date &&
          confirmAlert({
            message: `ERROR: ${this.state.errors.date}`,
            buttons: [{ label: "dismiss" }]
          })
        }
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>{ this.state.pool?.name }</NavbarBrand>
            <NavItem>
              { !_.isEmpty(this.state.modified) &&
                <React.Fragment>
                  <Button color="primary" onClick={this.handleSubmit}>save</Button>
                  <Button color="secondary" onClick={this.discardChanges}>x</Button>
                </React.Fragment>
              }
              { _.isEmpty(this.state.modified) &&
                <React.Fragment>
                  <Button color="info">
                    <Link to={`/admin/studio/pools/${this.props.poolId}`}>back to pool</Link>
                  </Button>
                  { this.state.status == "forecasted" &&
                    <Button color="success" onClick={this.handleProcess}>process</Button>
                  }
                </React.Fragment>
              }
            </NavItem>
          </Navbar>
          <Row>
            <Col>
              <div>
                <span>pending view logger jobs: {this.state.view_logger_jobs_count}</span>
              </div>
              <div>
                <span>pending view counter jobs: {this.state.view_counter_jobs_count}</span>
              </div>
              <div>
                <span>not yet counted watch times: {this.state.not_counted_watch_times_count}</span>
              </div>
              <div>
                <span>status: {this.state.status}</span>
              </div>
              <div>
                <span>dated: {moment(this.state.date).format("MM/DD/YYYY")}</span>
              </div>
              <div>
                <span>created: {moment(this.state.created_at).format("MM/DD/YYYY")}</span>
              </div>
              { this.state.status == "forecasted" &&
                <React.Fragment>
                  <div>
                    <span>validate by: {moment(this.state.validate_by).format("MM/DD/YYYY")}</span>
                  </div>
                  <div>
                    <span>{this.state.daysToValidate} days left to validate</span>
                  </div>
                </React.Fragment>
              }
            </Col>
            <Col>
              <Label for="pool_amount">Pool Amount</Label>
              { amountChange }
              <USDField
                disabled
                name="pool_amount"
                id="pool_amount"
                value={this.state.poolAmount}
                styles={styles}
              />
            </Col>
            <Col>
              <div>
                <Label for="total_watch_time">Total Watchtime(seconds)</Label>
                <CustomTextField
                  name="total_watch_time"
                  id="total_watch_time"
                  disabled
                  value={this.state.total_watch_time || ""}
                  styles={styles}
                />
              </div>
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
                  onChange={(e) => this.handleAmountChange(e)}
                />
              </div>
            </Col>
            <Col>
              <FormGroup className={this.state.modified["watch_time_rate"] && styles.yellow_text}>
                <Label for="watch_time_rate">Watchtime Rate($/sec)</Label>
                <USDField
                  name="watch_time_rate"
                  id="watch_time_rate"
                  value={this.state.watch_time_rate}
                  disabled={this.state.users?.length == 0}
                  styles={styles}
                  error={this.state.errors.watch_time_rate || ""}
                  onChange={(e) => this.handleRateChange(e)}
                />
              </FormGroup>
            </Col>
          </Row>
        </div>

        <div>
          <div>
            <Table striped hover>
              <thead>
                <tr>
                  <th>payout id</th>
                  <th>status</th>
                  <th>username</th>
                  <th>full name</th>
                  <th>total views</th>
                  <th>counted views</th>
                  <th>watchtime(%)</th>
                  <th>watchtime(sec)</th>
                  <th>amount</th>
                  <th>paying amount</th>
                  <th>remaining amount</th>
                </tr>
              </thead>
              { this.state.payouts &&
                <React.Fragment>
                  <tbody>
                    { this.state.payouts.map((po) => <Payout key={po.id} payout={po} />) }
                  </tbody>
                  <tfoot>
                    <tr>
                      <td>total</td>
                      <td colSpan={3}/>
                      <td>
                        { this.state.payouts.reduce((p,c) => p + c.total_views, 0) }
                      </td>
                      <td>
                        { this.state.payouts.reduce((p,c) => p + c.counted_views, 0) }
                      </td>
                      <td>{ this.payoutsSum("percent") }</td>
                      <td>{ this.payoutsSum("watch_time") }</td>
                      <td>
                        <USDFormat disabled value={this.payoutsSum("amount")} />
                      </td>
                      <td>
                        <USDFormat disabled value={this.payoutsSum("paying_amount")} />
                      </td>
                      <td>
                        <USDFormat disabled value={this.payoutsSum("remaining_amount")} />
                      </td>
                    </tr>
                  </tfoot>
                </React.Fragment>
              }
            </Table>
          </div>
        </div>
      </div>
    )
  }
}
