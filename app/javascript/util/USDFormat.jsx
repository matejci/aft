import React from 'react'
import NumberFormat from 'react-number-format'

function USDFormat(props) {
  const { inputRef, onChange, value, ...other } = props;

  return (
    <NumberFormat
      {...other}
      value={(value > 0 && value < 0.000001) ? Number(value).toFixed(20) : value}
      getInputRef={inputRef}
      onValueChange={(values) => {
        onChange &&
        onChange({
          target: {
            name: props.name,
            value: values.value
          }
        })
      }}
      thousandSeparator
      isNumericString
      prefix="$"
    />
  )
}

export default USDFormat;
