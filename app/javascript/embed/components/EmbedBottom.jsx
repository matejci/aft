
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import cx from 'classnames'
import styles from '../css/styles.css'

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class EmbedBottom extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      selectedPost: props.selectedPost,
      height: props.bottomHeight,
      fontSize: 14,
    }

    this.updateSelectedPost = this.updateSelectedPost.bind(this)
  }

  static getDerivedStateFromProps(props, state) {
    if (props.bottomHeight !== state.height) {
      return {
        height: props.bottomHeight,
        fontSize: props.bottomHeight/5
      }
    }
    return null
  }

  componentDidMount() {
    console.log("class EmbedBottom componentDidMount")
  }

  componentWillUnmount() {

  }

  updateSelectedPost = (selectedPost) => {
    this.setState({ selectedPost })

    // console.log("updateSelectedPost: ")
    // console.log(selectedPost)
  }

  render() {

    const profileImage = isEmpty(this.state.selectedPost) ? "" : this.state.selectedPost.user.profile_thumb_url
    const username = isEmpty(this.state.selectedPost) ? "" : "@"+this.state.selectedPost.user.username
    const displayName = isEmpty(this.state.selectedPost) ? "" : this.state.selectedPost.user.display_name

    const views = isEmpty(this.state.selectedPost) ? "0" : this.state.selectedPost.total_views
    const upvotes = isEmpty(this.state.selectedPost) ? "0" : this.state.selectedPost.upvotes_count
    const comments = isEmpty(this.state.selectedPost) ? "0" : this.state.selectedPost.comments_count

    return (
      <React.Fragment>
        <div className={styles.bottomContent} style={{ padding: `0 ${this.state.height/10}px` }}>
          <Container className={styles.bottomContainer + " h-100"} fluid>
            <Row className={styles.bottomRow + " row align-items-center justify-content-md-center"}>

              <Col xs={{ size: 6 }} className={styles.embedBottomCol}>
                <div className={styles.profileSection} style={{ height: this.state.height }}>
                  <div className={styles.profileImage} style={{ width: this.state.height/2, height: this.state.height/2, marginRight: this.state.height/10 }}>
                    <img src={ profileImage } className={styles.profileImageAvatar + " img-fluid rounded-circle"} />
                  </div>
                  <div className={styles.profileInfo}>
                    <h3 style={{ fontSize: this.state.fontSize, margin: `0 0 ${this.state.height/10} 0` }}>{ username }</h3>
                    <p style={{ fontSize: this.state.height/5.5 }}>{ displayName }</p>
                  </div>
                </div>
              </Col>

              <Col xs={{ size: 6 }} className={styles.embedBottomCol}>
                <div className={styles.postInfoSection} style={{ height: this.state.height }}>
                  
                  <span style={{ margin: `0 ${this.state.height/10}px`, lineHeight: `${this.state.height/5}px` }}>
                    <h5 style={{ fontSize: this.state.height/5.5, margin: `${this.state.height/10}px 0 0 0` }}>{ views }</h5>
                    <label style={{ fontSize: this.state.height/6.5, margin: `0 0 0 0` }}>views</label>
                  </span>

                  <span style={{ margin: `0 ${this.state.height/10}px`, lineHeight: `${this.state.height/5}px` }}>
                    <h5 style={{ fontSize: this.state.height/5.5, margin: `${this.state.height/10}px 0 0 0` }}>{ upvotes }</h5>
                    <label style={{ fontSize: this.state.height/6.5, margin: `0 0 0 0` }}>upvotes</label>
                  </span>

                  <span style={{ margin: `0 ${this.state.height/10}px`, lineHeight: `${this.state.height/5}px` }}>
                    <h5 style={{ fontSize: this.state.height/5.5, margin: `${this.state.height/10}px 0 0 0` }}>{ comments }</h5>
                    <label style={{ fontSize: this.state.height/6.5, margin: `0 0 0 0` }}>comments</label>
                  </span>

                </div>
              </Col>

            </Row>
          </Container>
        </div>
      </React.Fragment>
    )
  }

}