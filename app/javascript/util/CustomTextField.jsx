import React from 'react'
import { FormGroup } from 'reactstrap'
import TextField from '@material-ui/core/TextField'
import cx from 'classnames'

function CustomTextField(props) {
  const { onChange, error, styles, ...other } = props

  const defaultProps = {
    className: (error ? `${styles?.formControl} error` : styles?.formControl),
    InputProps: {
      className: styles.formWrapperInput,
      disableUnderline: true,
      autoComplete: "off"
    },
    InputLabelProps: {
      classes: {
        root: styles?.formInputLabel,
        focused: styles?.formInputLabelFocused,
        filled: styles?.formInputLabelFilled
      },
      shrink: true
    },
    variant:"filled"
  }

  const formClass = error ? cx(styles?.formGroup, styles?.error) : styles?.formGroup

  return (
    <FormGroup className={formClass}>
      <TextField {..._.merge(other, defaultProps)} onChange={onChange}/>
      <span className={styles?.errorMessage}>{error}</span>
    </FormGroup>
  )
}

export default CustomTextField;
