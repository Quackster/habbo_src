property pState

on construct me 
  registerMessage(#enterRoom, me.getID(), #leaveEntry)
  registerMessage(#leaveRoom, me.getID(), #enterEntry)
  registerMessage(#Initialize, me.getID(), #updateState)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#Initialize, me.getID())
  updateState(me, "reset")
  return TRUE
end

on enterEntry me 
  me.updateState(#hotelView)
  me.updateState(#entryBar)
  return TRUE
end

on leaveEntry me 
  return(me.updateState("reset"))
end

on getState me 
  return(pState)
end

on updateState me, tstate 
  if (tstate = "reset") then
    pState = tstate
    return(me.getInterface().hideAll())
  else
    if tstate <> #hotelView then
      if (tstate = "initialize") then
        pState = tstate
        return(me.getInterface().showHotel())
      else
        if (tstate = #entryBar) then
          pState = tstate
          return(me.getInterface().showEntryBar())
        else
          return(error(me, "Unknown state:" && tstate, #updateState, #minor))
        end if
      end if
    end if
  end if
end
