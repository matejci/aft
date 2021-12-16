
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'

import styles from './css/styles.css'

import SplashIndex from './components/SplashIndex'
import SubscriberIndex from './components/SubscriberIndex'
import {
  BrowserRouter as Router,
  Switch,
  Route
} from "react-router-dom";

class Splash extends React.Component {
  componentDidMount() {
    console.log("class Splash componentDidMount()")
  }

  render() {
    return (
      <Router>
        <Switch>
          <Route path='/keep_in_touch' component={SubscriberIndex} />
          <Route path='/' component={SplashIndex} />
        </Switch>
      </Router>
    )
  }
}


ReactDOM.render(
  <Splash/>,
  document.body.appendChild(document.getElementById('content'))
)
