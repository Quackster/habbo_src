on construct(me)
  registerMessage(#enterRoom, me.getID(), #leaveEntry)
  registerMessage(#leaveRoom, me.getID(), #enterEntry)
  registerMessage(#Initialize, me.getID(), #updateState)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#Initialize, me.getID())
  updateState(me, "reset")
  return(1)
  exit
end

on enterEntry(me)
  me.updateState(#hotelView)
  me.updateState(#entryBar)
  return(1)
  exit
end

on leaveEntry(me)
  return(me.updateState("reset"))
  exit
end

on getState(me)
  return(pState)
  exit
end

on updateState(me, tstate)
  if me = "reset" then
    pState = tstate
    return(me.getInterface().hideAll())
  else
    if me <> #hotelView then
      if me = "initialize" then
        pState = tstate
        executeMessage(#roomStatistic, "entry")
        return(me.getInterface().showHotel())
      else
        if me = #entryBar then
          pState = tstate
          return(me.getInterface().showEntryBar())
        else
          return(error(me, "Unknown state:" && tstate, #updateState))
        end if
      end if
      exit
    end if
  end if
end