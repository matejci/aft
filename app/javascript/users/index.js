
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col } from 'reactstrap'

import SignUpForm from './components/SignUpForm'
import styles from './css/styles.css'

class User extends React.Component {

	constructor(props) {
    super(props);
    this.state = {
      date: new Date(),
      causes: []
    };
  }

  componentDidMount() {

  }

  componentWillUnmount() {
  	clearInterval(this.timerID)
  }


  render() {
    const category = this.props.category
    return (
      <Container className={styles.users}>

        <Row className="justify-content-md-center align-items-center no-gutters">

          <Col md="5" style={{ height: "auto" }}>

            <SignUpForm />

            <div className={styles.footer}>

              <p>
                Copyright © {(new Date().getFullYear())} App for teachers, Inc.
              </p>

            </div>


          </Col>

        
        </Row>

      </Container>
    )
  }
}


ReactDOM.render(
  <User />,
  document.body.appendChild(document.createElement('div')),
)




