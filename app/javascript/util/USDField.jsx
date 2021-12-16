import React from 'react'
import USDFormat from './USDFormat'
import CustomTextField from './CustomTextField'

function USDField(props) {
  return (
    <CustomTextField {...props} InputProps={{inputComponent: USDFormat}} />
  )
}

export default USDField;
