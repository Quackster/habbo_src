on construct me 
  callAncestor(#construct, [me])
  executeMessage(#sound_machine_created, me.getID())
  return TRUE
end

on deconstruct me 
  executeMessage(#sound_machine_removed, me.getID())
  callAncestor(#deconstruct, [me])
  return TRUE
end

on select me 
  towner = 0
  tSession = getObject(#session)
  if tSession <> 0 then
    if tSession.get("room_owner") then
      towner = 1
    end if
  end if
  if the doubleClick and towner then
    tStateOn = 0
    if (me.pState = 2) then
      tStateOn = 1
    end if
    executeMessage(#sound_machine_selected, [#id:me.getID(), #furniOn:tStateOn])
  else
    return(callAncestor(#select, [me]))
  end if
  return TRUE
end

on changeState me, tStateOn 
  tNewState = 1
  if tStateOn then
    tNewState = 2
  end if
  return(getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:string(tNewState)]))
end

on setState me, tNewState 
  callAncestor(#setState, [me], tNewState)
  tStateOn = 0
  if (me.pState = 2) then
    tStateOn = 1
  end if
  executeMessage(#sound_machine_set_state, [#id:me.getID(), #furniOn:tStateOn])
end
