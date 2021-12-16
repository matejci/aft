import React from 'react'
import api from '../../../util/api'
import { Navbar, NavbarBrand, NavItem, Button, Table } from 'reactstrap'
import { Transition } from 'react-spring/renderprops'
import Pagination from 'rc-pagination'
import Create from './Create'

import Pool from './Pool'
import styles from '../../css/pool_styles.css'

export default class PoolsTable extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      errors: {},
      isOpen: false,
      pools: [],
      poolsTotal: 0,
      poolsTotalPages: 0,
      poolsLimit: 25,
      current: 1
    }

    this.toggle = this.toggle.bind(this)
    this.toggleEdit = this.toggleEdit.bind(this)
    this.fetchPools = this.fetchPools.bind(this)
  }

  componentDidMount() {
    this.fetchPools()
  }

  fetchPools() {
    api
      .get("/pools.json")
      .then(response => {
        this.setState({ pools: response.data.pools })
      })
  }

  toggle() {
    this.setState({
      isOpen: !this.state.isOpen,
      editing: null
    })
  }

  toggleEdit = (pool) => {
    this.setState({
      isOpen: !this.state.isOpen,
      editing: pool
    })
  }

  render() {
    return (
      <div className={styles.pools_table}>
        <div className={styles.navbar}>
          <Navbar>
            <NavbarBrand>Pools</NavbarBrand>
            <NavItem>
              <Button color="primary" onClick={() => this.toggle()}>
                +
              </Button>
            </NavItem>
          </Navbar>

          {!this.state.editing &&
            <Create
              isOpen={this.state.isOpen}
              toggle={this.toggle}
              updatePools={this.fetchPools}
            />
          }
          {this.state.editing &&
            <Create
              isOpen={this.state.isOpen}
              toggle={this.toggle}
              updatePools={this.fetchPools}
              pool={this.state.editing}
            />
          }
        </div>

        <Table className={styles.table}>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Amount</th>
              <th>Start Date</th>
              <th>End Date</th>
              <th style={{ minWidth: 200 }} colSpan={2}>Created At</th>
            </tr>
          </thead>
          <tbody>
            <Transition
              items={this.state.pools}
              keys={item => item.id}
              from={{ opacity: 0, height: 0 }}
              enter={{ opacity: 1, height: 50 }}
              leave={{ opacity: 0, height: 0, display: "none" }}
            >
              { item => props => (
                <Pool
                  style={props}
                  pool={item}
                  key={item.id}
                  toggleEdit={this.toggleEdit}
                  updatePools={this.fetchPools}
                />
              )}
            </Transition>
          </tbody>
        </Table>

        <Pagination onChange={this.onChange} current={this.state.current} pageSize={this.state.poolsLimit} total={this.state.poolsTotal} />
      </div>
    )
  }
}
