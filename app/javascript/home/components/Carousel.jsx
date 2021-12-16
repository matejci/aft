
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import ScrollMenu from 'react-horizontal-scrolling-menu'

import { Menu } from './Menu'

import cx from 'classnames'
import styles from '../css/styles.css'



export default class Carousel extends React.Component {

  constructor(props) {
    super(props)

    const selected = this.props.post
    const items = [this.props.post, ...this.props.post.items]
    // const items = [this.props.post, ...this.props.posts]
    this.menuItems = Menu(items, this.props.selectedPost._id, this.props.post, this.scrollToItem, this.props.updateSourceState)


    this.state = {
      items: items,
      selected: this.props.selectedPost._id.$oid,
    }

    this.handleClick = this.handleClick.bind(this)
    this.getIndex = this.getIndex.bind(this)
    this.scrollToItem = this.scrollToItem.bind(this)
    this.carouselNext = this.carouselNext.bind(this)
  }

  componentDidMount() {
    console.log("class Carousel componentDidMount")

    // this.carousel.handleArrowClickRight()

  }

  componentWillUnmount() {

  }

  handleClick = (post, updatePostsState) => (e) => {
    e.preventDefault()

    this.submitForm(post, updatePostsState)
  }

  scrollToItem = (data) => {
    console.log("scrollToItem")
    this.carousel.scrollTo(data._id.$oid)
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

  getIndex = (post) => {
    return this.state.items.findIndex(obj => obj._id === post._id);
  }

  carouselNext = () => {
    console.log("carouselNext")

    var postIndex = this.getIndex(this.props.selectedPost)
    console.log("postIndex")
    console.log(postIndex)

    var nextIndex = postIndex+1
    var nextItem = this.state.items[nextIndex]

    // console.log("nextItem")
    // console.log(nextItem)

    // console.log(" ")
    // console.log("nextIndex")
    // console.log(nextIndex)
    // console.log(" ")
    // console.log("this.state.items.length")
    // console.log(this.state.items.length)
    // console.log(" ")

    if (nextIndex < this.state.items.length) {
      // select next item in carousel
      this.setState({ selected: nextItem._id })
      this.props.updateSourceState(nextItem)
      this.scrollToItem(nextItem)

      console.log("nextItem._id")
      console.log(nextItem._id)
    }

    // this.carousel.setState({ selected: nextItem })
    // this.carousel.selected = nextItem
    // this.carousel.onItemClick(nextItem._id)


    // this.carousel.handleArrowClickRight()
  }

  render() {
    const post = this.props.post

    const menu = this.menuItems

    const Arrow = ({ text, className }) => {
      return (
        <div className={className}>
          <img src={"/assets/" + text + "-carousel-icon.png"} className="img-fluid" />
        </div>
      )
    }

    const ArrowLeft = Arrow({ text: 'left', className: cx(styles.carouselArrows, styles.arrowPrev) })
    const ArrowRight = Arrow({ text: 'right', className: cx(styles.carouselArrows, styles.arrowNext) })


    return (
      <React.Fragment>

        <ScrollMenu
          ref={el => (this.carousel = el)}
          data={menu}
          arrowLeft={ArrowLeft}
          arrowRight={ArrowRight}
          // hideArrows={hideArrows}
          // hideSingleArrow={hideSingleArrow}
          // transition={+transition}
          // onUpdate={this.onUpdate}
          onSelect={this.onSelect}
          // select={this.props.post}
          selected={this.state.selected}
          // translate={translate}
          alignCenter={false}
          // scrollToSelected={true}
          dragging={true}
          clickWhenDrag={true}
          // wheel={wheel}
          itemClass={styles.menuItem}
          wrapperClass={styles.menuItemWrapper}
          menuClass={styles.scrollMenuArrow}
        />

      </React.Fragment>
    )
  }

}
