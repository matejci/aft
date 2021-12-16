
import React from 'react'

import Switch from '@material-ui/core/Switch'
import Grid from '@material-ui/core/Grid'
import FormGroup from '@material-ui/core/FormGroup'
import FormControlLabel from '@material-ui/core/FormControlLabel'
import { withStyles } from '@material-ui/core/styles'

import Toggle from './Toggle'
import useDarkMode from 'use-dark-mode'

import cx from 'classnames'
import styles from "../../css/styles.css"

const DarkModeToggle = () => {
  const darkMode = useDarkMode(false)

  return (
    <FormGroup
      classes={{
        root: styles.darkModeOptions
      }}>

      <Grid component="label" container justify="center" alignItems="center" spacing={1}>
          <Grid item classes={{ root: styles.darkModeOptionsItem }}>Day</Grid>
          <Grid item>
            <Switch
              checked={darkMode.value}
              onChange={darkMode.toggle}
              color="primary"
              name="darkModeToggle"
              inputProps={{ 'aria-label': 'dark mode checkbox' }}
            />
          </Grid>
          <Grid item classes={{ root: styles.darkModeOptionsItem }}>Night</Grid>
        </Grid>
    </FormGroup>
  )

  /*
  return (
    <div className="dark-mode-toggle">
      <button type="button" onClick={darkMode.disable}>
        ☀
      </button>
      <Toggle checked={darkMode.value} onChange={darkMode.toggle} />
      <button type="button" onClick={darkMode.enable}>
        ☾
      </button>
    </div>
  )
  */
}

export default DarkModeToggle
