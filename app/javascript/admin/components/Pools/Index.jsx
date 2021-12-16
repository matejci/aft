import React from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'

import PoolsTable         from './PoolsTable'
import PoolDetail         from './PoolDetail'
import PoolIntervalDetail from './PoolIntervalDetail'
import ViewData           from '../Views/ViewData'
import ViewPostData       from '../Views/ViewPostData'
import ViewViewerData     from '../Views/ViewViewerData'

function PoolsIndex() {
  return (
    <Router>
      <Switch>
        <Route
          exact
          path="/admin/studio/pools/views/:date/:user_id/:post_id/viewer/:viewer_id?"
          render={({match}) => {return(
            <ViewViewerData
              date={match.params.date}
              userId={match.params.user_id}
              postId={match.params.post_id}
              viewerId={match.params.viewer_id} />
          )}}
        />
        <Route
          exact
          path="/admin/studio/pools/views/:date/:user_id/:post_id"
          render={({match}) => {return(
            <ViewPostData
              date={match.params.date}
              userId={match.params.user_id}
              postId={match.params.post_id} />
          )}}
        />
        <Route
          exact
          path="/admin/studio/pools/views/:date/:user_id"
          render={({match}) => {return(
            <ViewData date={match.params.date} userId={match.params.user_id} />
          )}}
        />
        <Route
          exact
          path="/admin/studio/pools/:pool_id/intervals/:id"
          render={({match}) => {return(
            <PoolIntervalDetail poolId={match.params.pool_id} intervalId={match.params.id} />
          )}}
        />
        <Route
          exact
          path="/admin/studio/pools/:id"
          render={({match}) => <PoolDetail poolId={match.params.id} />}
        />
        <Route path="/admin/studio/pools/" component={PoolsTable} />
      </Switch>
    </Router>
  )
}

export default PoolsIndex;
