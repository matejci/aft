import React from 'react'
import _ from 'lodash'
import api from '../../../util/api'
import moment from 'moment'
import { Button, Form, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap'
import USDField from '../../../util/USDField'
import CustomTextField from '../../../util/CustomTextField'

import styles from '../../css/styles.css'

const initialState = {
  errors: {},
  nestedModal: false,
  name: '',
  amount: '',
  start_date: moment().format("YYYY-MM-DD"),
  editing: false
}

export default class Create extends React.Component {

  constructor(props) {
    super(props)
    this.state = initialState

    this.toggle = this.toggle.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  componentDidMount() {
    if (this.props.pool) {
      this.setState({ ...this.props.pool, editing: true })
    } else {
      this.setState(initialState)
    }
  }

  formatDate = (date) => {
    return moment(date).format("YYYY-MM-DD")
  }

  handleInputChange(e) {
    this.setState({
      [e.target.name]: e.target.value
    })
  }

  toggle() { this.props.toggle() }

  handleSubmit = (e, updateState) => {
    e.preventDefault()

    var postData, request

    postData = {
      pool: {
        name: this.state.name,
        amount: this.state.amount,
        start_date: this.state.start_date
      }
    }

    if (this.state.editing) {
      request = api.patch(`/pools/${this.props.pool.id}.json`, postData)
    } else {
      request = api.post("/pools.json", postData)
    }

    request
      .then(response => {
        updateState()
        this.toggle()
        this.setState(initialState)
      })
      .catch(error => {
        console.error(`error: ${error}`)
        if (error.response) {
          console.log(`JSON.parse error=> ${JSON.stringify(error.response.data)}`)
          this.setState({ errors: error.response.data })
        }
      })
  }

  render() {
    return (
      <React.Fragment>
        <Modal isOpen={this.props.isOpen} toggle={this.toggle} className={styles.modal}>
          <ModalHeader toggle={this.toggle}>
            {this.state.editing ? `Update ${this.props.pool.name}` : "Add Pool"}
          </ModalHeader>

          <ModalBody>
            <Form className={styles.adminForm}>
              <CustomTextField
                label="Name"
                name="name"
                id="name"
                value={this.state.name}
                error={this.state.errors.name}
                onChange={(e) => this.handleInputChange(e)}
                styles={styles}
              />

              <USDField
                label="Amount"
                name="amount"
                id="amount"
                value={this.state.amount}
                error={this.state.errors.amount}
                styles={styles}
                onChange={(e) => this.handleInputChange(e)}
              />

              <CustomTextField
                id='start_date'
                label='Start Date'
                type='date'
                name='start_date'
                value={this.state.start_date}
                error={this.state.errors.start_date}
                disabled={!!this.state.processed_amount}
                styles={styles}
                onChange={(e) => this.handleInputChange(e)}
              />
            </Form>

          </ModalBody>

          <ModalFooter>
            <Button color="primary" onClick={(e) => this.handleSubmit(e, this.props.updatePools)}>
              {this.state.editing ? "Update" : "Add"}
            </Button>
            {" "}
            <Button color="secondary" onClick={this.toggle}>Cancel</Button>
          </ModalFooter>
        </Modal>
      </React.Fragment>
    )

  }

}
