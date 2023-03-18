on deconstruct me
  callAncestor(#deconstruct, [me])
  executeMessage(#roomdimmer_removed, me.getID())
  return 1
end

on define me, tProps
  callAncestor(#define, [me], tProps)
  if voidp(tProps[#stripId]) then
    executeMessage(#roomdimmer_defined, me.getID())
  end if
  return 1
end

on select me
  towner = 0
  tSession = getObject(#session)
  if tSession <> 0 then
    if tSession.GET("room_owner") then
      towner = 1
    end if
  end if
  if the doubleClick and towner then
    tStateOn = 0
    if me.pState = 2 then
      tStateOn = 1
    end if
    executeMessage(#roomdimmer_selected, [#id: me.getID(), #furniOn: tStateOn])
  else
    return callAncestor(#select, [me])
  end if
  return 1
end

on setState me, tNewState
  tNewState = string(tNewState)
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  if tNewState.item.count < 5 then
    callAncestor(#setState, [me], 1)
    return 0
  end if
  tstate = tNewState.item[1]
  tPresetID = tNewState.item[2]
  tEffectID = tNewState.item[3]
  tColor = tNewState.item[4]
  tLightness = tNewState.item[5]
  the itemDelimiter = tDelim
  callAncestor(#setState, [me], tstate - 1)
  tLightness = max(integer(tLightness), 77)
  tStateData = [:]
  tStateData.setaProp(#dimmerID, me.getID())
  tStateData.setaProp(#isOn, tstate = 2)
  tStateData.setaProp(#presetID, integer(tPresetID))
  tStateData.setaProp(#effectID, integer(tEffectID))
  tStateData.setaProp(#color, rgb(tColor))
  tStateData.setaProp(#lightness, tLightness)
  executeMessage(#roomdimmer_set_state, tStateData)
end
