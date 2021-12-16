
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { Container, Row, Col } from 'reactstrap'

import CreateForm from './components/CreateForm'
import styles from './css/styles.css'

class Create extends React.Component {

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

          <Col md="8" style={{ height: "auto" }}>

            <CreateForm />

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
  <Create />,
  document.body.appendChild(document.createElement('div')),
)




