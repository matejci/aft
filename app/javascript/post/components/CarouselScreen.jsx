
import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import { animated } from 'react-spring'
import { Container, Row, Col } from 'reactstrap'
import { confirmAlert } from 'react-confirm-alert'
import '!style-loader!css-loader!react-confirm-alert/src/react-confirm-alert.css' // Import css

import NumberFormat from 'react-number-format'
import { useAlert } from 'react-alert'

import useMeasure from 'react-use-measure'

import ScrollMenu from 'react-horizontal-scrolling-menu'

import { Menu } from './Menu'

import cx from 'classnames'
import styles from '../css/styles.css'
import imagePath from '../../shared/components/imagePath'

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

export default class CarouselScreen extends React.Component {

  constructor(props) {
    super(props)

    // const element = this.props.post
    // const items = element ? element.items : []
    // const selectedPost = items ? items.find((item)=> item.id == element.selected_id ) : {}

    this.state = {
      page: 1,
      items: [],
      selected: null,
      selectedPost: {},
      translate: 0,
      transition: 0.3,
      firstItemVisible: false,
      lastItemVisible: false,
    }

    this.callToAction = this.callToAction.bind(this)

    this.syncSelected = this.syncSelected.bind(this)
    this.syncTranslate = this.syncTranslate.bind(this)

    this.endOfTakkosAlert = this.endOfTakkosAlert.bind(this)

    this.handleMouseUp = this.handleMouseUp.bind(this)
    this.handleFirstItemVisible = this.handleFirstItemVisible.bind(this)
    this.handleLastItemVisible = this.handleLastItemVisible.bind(this)

    this.getTakkos = this.getTakkos.bind(this)

    this.getIndex = this.getIndex.bind(this)
    this.scrollToItem = this.scrollToItem.bind(this)
    this.carouselNext = this.carouselNext.bind(this)

    this.onUpdate = this.onUpdate.bind(this)
    this.onSelect = this.onSelect.bind(this)
  }

  static getDerivedStateFromProps(props, state) {
    if (props.items !== state.items) {
      return {
        page: props.page,
        items: props.items,
        selected: props.selectedPost.id,
        selectedPost: props.selectedPost,
        // lastItemVisible: props.lastItemVisible
      }
    }
    return null
  }

  componentDidMount() {
    console.log("class CarouselScreen componentDidMount")

    // this.getTakkos(this.props.originalPost)
  }

  componentWillUnmount() {

  }

  endOfTakkosAlert = () => {
    confirmAlert({
      message: "You've reached the end!",
      buttons: [
        { label: "Okay!" }
      ]
    })
  }

  // componentDidUpdate(prevProps, prevState) {
  //   if (prevProps)
  // }

  syncTranslate = (translate) => {
    this.setState({ translate })
  }

  syncSelected = (items, selectedPost) => {
    this.setState({ items: items, selectedPost: selectedPost, selected: selectedPost.id })
  }

  getTakkos = (originalPost) => {
    const nextPage = this.state.page+1
    if (nextPage > this.props.total_pages) {
      // this.endOfTakkosAlert()
      return
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    var getHeaders = {
      headers: {
        'X-CSRF-Token': csrfToken,
        'HTTP-X-APP-TOKEN': appToken,
        'APP-ID': appId
      }
    }

    // get item
    axios.get(`/posts/`+originalPost.parent_id+`/takkos.json?per_page=`+ 7 +`&page=`+ nextPage, getHeaders)
      .then(response => {
        const data = response.data
        const takkos_count = response.data.takkos_count
        // this.setState({ post: item })

        console.log("getTakkos data: ")
        console.log(data)

        console.log("takkos_count: ")
        console.log(takkos_count)

        this.setState({
          items: [
            ...this.state.items,
            ...data.data.items
          ],
          // lastItemVisible: false,
        }, () => {
          console.log('this.setState')
          console.log(this.state.items)
        })

        this.props.updateItemsState(data.data.items, nextPage, data.total_pages)

      })
      .catch(error => {
        console.error("error: " + error)
        console.log("JSON.parse error=> " + JSON.stringify(error.response.data))
        // this.setState({ errors: error.response.data })
      })
  }

  handleMouseUp = () => {
    console.log("handleMouseUp")
    const translate = this.carousel.state.translate >= 0 ? 0 : this.carousel.state.translate
    console.log(this.carousel.state.translate)
    console.log(translate)
    this.setState({ translate })
  }

  handleFirstItemVisible = () => {
    if (this.state.firstItemVisible) {
      // console.log(`this.carousel.state.translate ${!isEmpty(this.carousel) ? this.carousel.state.translate : 'no carousel state'}`)
      if (isEmpty(this.carousel)) {
        // console.log("handleFirstItemVisible ignored")
        return null
      }

      if (this.carousel.state.translate == 0) {
        if (this.state.translate !== 0) {
          // console.log("handleFirstItemVisible setState expensive")
          this.setState({ translate: this.carousel.state.translate })
        }
      }
    } else {
      console.log("handleFirstItemVisible")
      this.setState({ firstItemVisible: true })
    }

  }

  handleLastItemVisible = () => {
    // console.log("handleLastItemVisible")

    if (isEmpty(this.carousel)) {
      // console.log("handleLastItemVisible ignored")
      return null
    }

    if (this.state.lastItemVisible) {
      // console.log(`this.carousel.state.translate ${!isEmpty(this.carousel) ? this.carousel.state.translate : 'no carousel state'}`)

      const diff = this.carousel.menuWidth-this.carousel.allItemsWidth
      if (this.carousel.state.translate == diff) {
        if (this.state.translate !== this.carousel.state.translate) {
          // console.log("handleLastItemVisible setState expensive")
          this.setState({ translate: this.carousel.state.translate })
        }
      }
    } else {
      console.log("handleLastItemVisible process")
      this.setState({ lastItemVisible: true })

      // if (this.props.updatelastItemVisible(true)) {
      //   // change occured
      //   this.getTakkos(this.props.originalPost)
      // }
    }

    if (this.props.updatelastItemVisible(true, this.carousel.state.translate)) {
      // change occured
      // this.getTakkos(this.props.originalPost)
    }
  }

  scrollToItem = (data) => {
    console.log("scrollToItem")
    this.carousel.scrollTo(data.id)
  }

  getIndex = (post) => {
    return this.state.items.findIndex(obj => obj.id === post.id)
  }

  callToAction = (e) => {
    e.preventDefault()

    // redirect to app store
    console.log("callToAction")

    const url = 'https://apple.co/3w65qgG'
    const win = window.open(url, '_blank')
    if (win != null) {
      win.focus()
    }
  }

  carouselNext = () => {
    console.log("carouselNext")

    var postIndex = this.getIndex(this.state.selectedPost)
    console.log("postIndex")
    console.log(postIndex)

    var nextIndex = postIndex+1
    var nextItem = this.state.items[nextIndex]

    if (nextIndex < this.state.items.length) {
      // select next item in carousel
      this.setState({ selected: nextItem.id, selectedPost: nextItem })
      this.props.updateSourceState(nextItem, this.carousel.state.translate)
      this.scrollToItem(nextItem.id)

      console.log("nextItem.id")
      console.log(nextItem.id)
    } else {
      // loop
      var firstItem = this.state.items[0]

      this.setState({ selected: firstItem.id, selectedPost: firstItem })
      this.props.updateSourceState(firstItem, this.carousel.state.translate)
      this.scrollToItem(firstItem.id)
    }
    // this.carousel.onItemClick(nextItem._id)


    // this.carousel.handleArrowClickRight()
  }

  onUpdate = ({ translate }) => {
    this.setState({ translate })
    // this.carousel.setInitial()
  }

  onSelect = (key) => {
    console.log("onSelect - key: " + JSON.stringify(key))

    const newlySelected = this.state.items.find((item)=> item.id == key )
    this.props.updateSourceState(newlySelected, this.carousel.state.translate)
    this.setState({ selected: key, selectedPost: newlySelected })
  }

  carousel = carousel => {
    this.carousel = carousel
  }



  render() {

    const Arrow = ({ text, className }) => {
      return (
        <div className={className}>
          <img src={imagePath(text + "-carousel-icon.png")} className="img-fluid" />
        </div>
      )
    }

    const ArrowLeft = Arrow({ text: 'left', className: cx(styles.carouselArrows, styles.arrowPrev) })
    const ArrowRight = Arrow({ text: 'right', className: cx(styles.carouselArrows, styles.arrowNext) })

    const MenuItem = (props) => {
      const { index, item, selected, width, height, borderRadius } = props

      const margins = 5
      const sideMargins = 12
      const itemsCount = this.state.items.length
      const lastItemIndex = itemsCount-1

      return (
        <div
          style={{ marginLeft: (index==0) ? sideMargins : margins, marginRight: (index==lastItemIndex) ? sideMargins : margins, marginBottom: sideMargins }}
          className={styles.menuItemLink}
        >
          <div className={selected ? cx(styles.menuItemContent, styles.selected) : styles.menuItemContent} style={{width: width, height: height, backgroundImage: "url('" + item.media_thumbnail.url + "')", borderRadius: borderRadius}}>
            


          </div>
        </div>
      )
    }

    const Menu = (items, selected, width, height, borderRadius) =>
      items.map((item, index) => {
        return <MenuItem
                  index={index}
                  item={item}
                  key={item.id}
                  selected={selected}
                  width={width}
                  height={height}
                  borderRadius={borderRadius}
                />
      }
    )

    const Carousel = () => {

      const [ref, bounds] = useMeasure()

      const widthParent = Math.round(bounds.width)
      const heightParent = Math.round(bounds.height)

      const verticalPadding = 12
      const height = heightParent-(verticalPadding*2)
      const width = (9/16)*height
      // const horizontalPadding = heightParent/18
      const horizontalPadding = heightParent/5
      const bottomPadding = heightParent/25
      const borderRadius = width/6

      const iconsWidth = heightParent/8
      const iconsHeight = heightParent/8
      const iconsFontSize = heightParent/13

      const menu = Menu(this.state.items, this.state.selected, width, height, borderRadius)
      const fontSize = (bounds.width < 767) ? bounds.height/11.5 : bounds.height/12

      return (
        <React.Fragment>
          <div className={styles.carouselBox} style={{ width: (bounds.width < this.carousel.menuWidth) ? widthParent : 'auto' }}>
            
            <div className={styles.carouselInfo}>
              <div className={styles.postViews}>
                <h3 style={{ fontSize: fontSize*0.8 }}>
                  <NumberFormat value={this.state.selectedPost.total_views} displayType={'text'} thousandSeparator={true} suffix={this.state.selectedPost.total_views > 1 ? ' views' : ' view'} decimalScale={0} />
                </h3>
              </div>

              <div className={styles.postTitle} style={{ margin: `${heightParent/50}px 0 0 0` }}>
                <h1 style={{ fontSize: fontSize }}>{ this.state.selectedPost.title }</h1>
              </div>

              <div className={styles.postMetrics} style={{ margin: `${heightParent/10}px 0 0 0` }}>
                <div className={styles.leftCol}>
                  <div className={styles.votes} style={{ columnGap: heightParent/11 }}>
                    <a href="#" onClick={ (e) => this.callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-upvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
                    <NumberFormat value={this.state.selectedPost.upvotes_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} />
                    <a href="#" onClick={ (e) => this.callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-downvote-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
                  </div>
                </div>

                <div className={styles.rightCol}>
                  <div className={styles.postActions} style={{ columnGap: heightParent/9 }}>
                    <a href="#" onClick={ (e) => this.callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-ellipsis-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div></a>
                    <a href="#" onClick={ (e) => this.callToAction(e) } className={styles.postActionsLinkGroup}>
                      <div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-comments-icon.png')}`, width: iconsWidth, height: iconsHeight }}></div>
                      <div className={styles.metric}><NumberFormat value={this.state.selectedPost.comments_count} style={{ fontSize: iconsFontSize }} displayType={'text'} thousandSeparator={true} suffix={''} decimalScale={0} /></div>
                    </a>
                    <a href="#" onClick={ (e) => this.callToAction(e) }><div className={styles.icons} style={{ backgroundImage: `url('${imagePath('post-add-takko-icon.png')}`, minWidth: iconsWidth*1.2, height: iconsHeight }}></div></a>
                  </div>
                </div>
              </div>
            </div>

            { !isEmpty(this.state.items) && (
              <div className={styles.scrollWrap} ref={ref} /*onMouseUp={this.handleMouseUp}*/ >
                <ScrollMenu
                  ref={el => (this.carousel = el)}
                  data={menu}
                  alignCenter={false}
                  alignOnResize={false}
                  // arrowLeft={ArrowLeft}
                  // arrowRight={ArrowRight}
                  onFirstItemVisible={this.handleFirstItemVisible}
                  onLastItemVisible={this.handleLastItemVisible}
                  hideArrows={false}
                  hideSingleArrow={false}
                  onUpdate={this.onUpdate}
                  onSelect={this.onSelect}
                  selected={this.state.selected}
                  translate={this.state.translate}
                  scrollToSelected={false}
                  dragging={true}
                  clickWhenDrag={false}
                  useButtonRole={false}
                  itemClass={styles.menuItem}
                  arrowClass={styles.arrowClass}
                  arrowDisabledClass={styles.arrowDisabledClass}
                  innerWrapperClass={styles.innerWrapperClass}
                  wrapperClass={styles.menuItemWrapper}
                  menuClass={styles.scrollMenu}
                  disableTabindex={false}
                  inertiaScrolling={true}
                  wheel={false}
                />
              </div>
            )}

          </div>
        </React.Fragment>
      )
    }


    return (
      <React.Fragment>

        <Carousel />

      </React.Fragment>
    )
  }

}
