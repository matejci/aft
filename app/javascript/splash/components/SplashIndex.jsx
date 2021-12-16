
import React from 'react'
import { Container, Row, Col } from 'reactstrap'
import cx from 'classnames'
import styles from "../css/styles.css"
import imagePath from 'shared/components/imagePath'

export default class SplashIndex extends React.Component {
  constructor(props) {
    super(props)

    this.handleSubmit = this.handleSubmit.bind(this)
    this.animateCSS = this.animateCSS.bind(this)
  }

  handleSubmit(e) {
    e.preventDefault()
    var email = document.getElementById('new_subscriber').getElementsByTagName('input')[0].value

    this.props.history.push('/keep_in_touch', { subscriber: { email: email } })
  }

  animateCSS() {
    const node = document.getElementById('new_subscriber')

    node.scrollIntoView()
    node.classList.add('animated', 'shake')

    function handleAnimationEnd() {
        node.classList.remove('animated', 'shake')
        node.removeEventListener('animationend', handleAnimationEnd)

        if (typeof callback === 'function') callback()
    }

    node.addEventListener('animationend', handleAnimationEnd)
    node.getElementsByTagName('input')[0].focus()
  }

  render() {

    return (
      <React.Fragment>
        <Container className={styles.splash} fluid>
          <Row className={cx(styles.splashRow, styles.splash_header)}>
            <Col xs={{ size: 12, order: 1 }} className={cx(styles.section, styles.sectionLeft)}>
              <a href="/"><img src={ imagePath('white_takko.png') } /></a>
            </Col>
          </Row>

          <Row className={cx(styles.splashRow, styles.splash_main) + " justify-content-center"}>
            <Col xs={{ size: 11, order: 2 }} sm={{ size: 11 }} md={{ size: 10 }}>
              <Row className={styles.splashRow + " h-100 justify-content-center"}>
                <Col xs={{ size: 12, order: 1 }} className={styles.testt + ' col-md'}>
                  <div style={ {backgroundImage: `url(${imagePath('takko_carousel.png')})`}}>
                  </div>
                </Col>

                <Col xs={{ size: 12, order: 2 }} md={{ size: 'auto'}} className={styles.splash_col}>
                  <div className={styles.rt_column}>
                    <h1>Bringing <i>social</i> back to social media</h1>
                    <p>Join the next generation video community where you can collaborate, have conversations, start trends, and make money together.</p>
                    <a href='https://apps.apple.com/us/app/takko-your-video-community/id1556959297' className={styles.main_btn}>
                      <img src={ imagePath('apple_icon.png') }/>
                      Download Now
                    </a>
                    <a className={styles.main_btn} onClick={this.animateCSS}>
                      <img src={ imagePath('android_icon.png') }/>
                      Android Coming Soon
                    </a>
                  </div>
                </Col>
              </Row>
            </Col>
          </Row>

          <Row className={cx(styles.splashRow, styles.splash_footer)}>
            <Col xs={{ size: 12, order: 2 }} md={{ size: true, order: 1 }} className={cx(styles.section, styles.sectionLeft)}>
              <Row>
                <Col xs={{ size: 12, order: 2 }} md={{ size: true, order: 1 }} className={styles.footer_left}>
                  <a href='/'><img src={ imagePath('white_takko.png') } className={ styles.takko_icon }/></a>
                  <a href='/guidelines'>Community Guidelines</a>
                  <a href='/terms'>Terms of Use</a>
                  <a href='/privacy'>Privacy Policy</a>
                  <p>Copyright © {(new Date().getFullYear())} Takko, Inc.</p>
                  <div className={ styles.social_icons }>
                    <a href='https://discord.gg/RhKFnZazvf'><img src={ imagePath('icons/discord.png') }/></a>
                    <a href='https://www.youtube.com/channel/UCzGWJ9_sFtzv_JTDVDnoGjw/featured'><img src={ imagePath('icons/youtube.png') }/></a>
                    <a href='https://twitter.com/takkoapp?lang=en'><img src={ imagePath('icons/twitter.png') }/></a>
                    <a href='https://www.linkedin.com/company/takko'><img src={ imagePath('icons/linkedin.png') }/></a>
                  </div>
                </Col>

                <Col xs={{ size: 12, order: 1 }} md={{ size: 'auto', order: 2 }} className={styles.footer_middle}>
                  Need Help?
                  <a href='mailto:support@takkoapp.com'>support@takkoapp.com</a>
                  Want to advertise?
                  <a href='mailto:advertising@takkoapp.com'>advertising@takkoapp.com</a>
                  We’re Hiring!
                  <a href='mailto:careers@takkoapp.com'>careers@takkoapp.com</a>
                </Col>
              </Row>
            </Col>

            <Col xs={{ size: 12, order: 1 }} md={{ size: 'auto', order: 2 }} className={styles.footer_right}>
              <h2>Let’s keep in touch</h2>
              <p>Sign up to get updates about App for teachers</p>
              <form id='new_subscriber' onSubmit={this.handleSubmit}>
                <input placeholder='Your email here'/>
                <button type='submit' form='new_subscriber'><img src={ imagePath('icons/yellow_submit.png') }/></button>
              </form>
            </Col>
          </Row>
        </Container>
      </React.Fragment>
    )
  }
}
