
import React from 'react'

import { makeObservable } from "../Observable"

const playerDefault = makeObservable({ width: 0, count: 0 })

function isEmpty(obj) {
  for(var key in obj) {
      if(obj.hasOwnProperty(key))
          return false
  }
  return true
}

const usePlayer = (init) => {
	const playerStore = isEmpty(init) ? playerDefault : init
  const [player, setPlayer] = React.useState(playerStore.get())

  React.useEffect(() => {
    return playerStore.subscribe(setPlayer)
  }, [])

  const actions = React.useMemo(() => {
    return {
    	init: (width) => playerStore.set({ ...player, width }),
      setWidth: (width) => playerStore.set({ ...player, width }),
      incrementCount: () => playerStore.set({ ...player, count: player.count + 1 }),
      decrementCount: () => playerStore.set({ ...player, count: player.count - 1 }),
    }
  }, [player])

  return {
    state: player,
    actions
  }
}

export { playerDefault, usePlayer }