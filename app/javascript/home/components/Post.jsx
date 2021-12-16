
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import styles from '../css/styles.css'

// import { parse, stringify } from 'flatted/esm' // circular JSON parser

export default class Post extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      name: '',
    }

    this.handleClick = this.handleClick.bind(this)
    this.handleEditClick = this.handleEditClick.bind(this)
  }

  componentDidMount() {
    console.log("class Post componentDidMount")
  }

  componentWillUnmount() {

  }

  handleClick = (post, updatePostsState) => (e) => {
    e.preventDefault()

    this.submitForm(post, updatePostsState)
  }

  handleEditClick = (post, updatePostsState) => (e) => {
    e.preventDefault()

    this.postEditModal.toggle()

    // this.submitForm(post, updatePostsState)
  }

  submitForm(post, updatePostsState) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var postHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // console.log("------- post._id.$oid -------: " + JSON.stringify(post))
    var postData = {
      params: {
        post_type: post._id.$oid
      }
    }


    // axios.post(`/post_types.json`, postData, postHeaders)
    axios.delete(`/posts/${post._id.$oid}.json`, postHeaders)
      .then(response => {
        // console.log("response: " + response)px
        // window.location = '/'
        // console.log("JSON.parse success => " + JSON.stringify(response.data))

        // update Posts Type State on index.js
        updatePostsState(response.data.posts)
        // console.log("response.data: " + response.data.post_types)
      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        this.setState({ errors: error.response.data })
      })
  }

  submitConfirm = (adminSource, updatePostsState) => {
    confirmAlert({
      title: 'Confirm to submit',
      message: 'Are you sure to do this.',
      buttons: [
        {
          label: 'Yes',
          onClick: () => this.submitForm(adminSource, updatePostsState)
        },
        {
          label: 'No',
          // onClick: () => alert('Click No')
        }
      ]
    })
  }

  render() {
    const post = this.props.post

    // console.log("post animated.div: " + JSON.stringify(this.props.style))

    return (
      <Col style={this.props.style} className={styles.postCol} xs={{ size: 12 }} md={{ size: 3 }}>
        <a href="#" onClick={ (e) => this.props.toggleModal(e, post) } className={styles.postLink}>
          <div className={styles.post} style={{backgroundImage: "url('" + post.media_thumbnail.url + "')"}}>

            {/* post.title */}

          </div>

        </a>
      </Col>
    )
  }

  // render() {
  //   const post = this.props.post

  //   // console.log("post animated.div: " + JSON.stringify(this.props.style))

  //   return (
  //     <tr>
  //       <th scope="row">2</th>
  //       <td>Jacob</td>
  //       <td>Thornton</td>
  //       <td>@fat</td>
  //     </tr>
  //     <div style={this.props.style} className={styles.item}>
  //       <div className={styles.post}>
  //         {post._id.$oid} |
  //         {post.email}
  //         <span style={{fontSize:'12px'}}>
  //           {/*<a href="#" onClick={this.handleEditClick(post, this.props.updatePostsState).bind(this)} style={{color:'green'}}>Edit {post.name}</a>*/}
  //         </span>
  //       </div>

  //       {/*<PostsEditModal className="postEditModal" ref={instance => { this.postEditModal = instance }} post={ post } updatePostsState={ this.props.updatePostsState } />*/}
  //     </div>
  //   )
  // }
}
