
import React, { useEffect, useState } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import axios from 'axios'
import api from '../../../util/api'
import { Transition } from 'react-spring/renderprops'
import { Row, Col, Input, Table } from 'reactstrap'
import '!style-loader!css-loader!rc-pagination/assets/index.css'

import cx from 'classnames'
import styles from '../../css/styles.css'

const SupportedVersions = () => {
  const [apps, setApps] = useState([])
  const [editingAppId, setEditingAppId] = useState([])

  useEffect(() => {
    api.get(`/apps.json`)
      .then(response => {
        const apps = response.data
        setApps(apps)
    })
  }, [])

  const saveApp = (app) => {
    const data = { app: { supported_versions: app.supported_versions } }

    api.patch(`/apps/${app.id}.json`, data)
  }

  const setEditingApp = (appId) => {
    if (appId === editingAppId) {
      setEditingAppId(null)
      const app = apps.find(a => a.id === appId)
      saveApp(app)
    } else {
      setEditingAppId(appId)
    }
  }

  const handleAppIdChange = (appId, e) => {
    const newVal = e.target.value.replace(/\s/g, '')
    const app = apps.find(a => a.id === appId)
    app.supported_versions = newVal.split(',')
    setApps([...apps])
  }

  return (
    <React.Fragment>
      <Row className={styles.splashRow + " h-100"}>
        <Col md={{ size: 12, order: 1 }} className={styles.content} style={{overflow: 'scroll'}}>
          <div className={styles.header}>
            Total apps: {apps.length}
          </div>

          <div className={styles.subheader}>
            Enter app versions separated by comma (spaces will be ignored)
          </div>
          <Table>
            <thead>
              <tr>
                <th>App ID</th>
                <th>Name</th>
                <th>Supported versions</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <Transition
                items={apps}
                keys={item => item.id}
                from={{ opacity: 0, height: 0 }}
                enter={{ opacity: 1, height: 50 }}
                leave={{ opacity: 0, height: 0, display: 'none' }}
              >
                { item => props => (
                  <tr style={props.style} className={styles.item}>
                    <th scope="row">{item.id}</th>
                    <td>{item.name}</td>
                    { editingAppId === item.id
                        ? <AppIdEditingField
                            appId={editingAppId}
                            supportedVersions={item.supported_versions}
                            handleAppIdChange={handleAppIdChange}
                          />
                        : <td>{item.supported_versions.join(', ')}</td>
                    }
                    <td><a href='javascript:void(0)' onClick={setEditingApp.bind(this, item.id)}>{ editingAppId === item.id ? 'Submit' : 'Edit' }</a></td>
                  </tr>
                )}
              </Transition>
            </tbody>
          </Table>
        </Col>
      </Row>
    </React.Fragment>
  )
}

const AppIdEditingField = ({appId, supportedVersions, handleAppIdChange}) => (
  <td>
     <Input
      name="supported_versions"
      type="text"
      value={supportedVersions}
      onChange={handleAppIdChange.bind(this, appId)} />
  </td>
)

export default SupportedVersions
