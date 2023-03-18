property pState, pBlinkCounter

on prepare me, tdata
  me.setState(tdata[#stuffdata])
  return 1
end

on updateStuffdata me, tValue
  me.setState(tValue)
end

on setState me, tValue
  if me.pSprList.count < 5 then
    return 0
  end if
  pBlinkCounter = 0
  pState = tValue
  me.pSprList[5].visible = pState = "1"
  return 1
end

on update me
  if pState <> "1" then
    return 1
  end if
  if me.pSprList.count < 5 then
    return 0
  end if
  if pBlinkCounter = 0 then
    me.pSprList[5].visible = 1
  end if
  if pBlinkCounter = 20 then
    me.pSprList[5].visible = 0
  end if
  pBlinkCounter = pBlinkCounter + 1
  if pBlinkCounter > 45 then
    pBlinkCounter = 0
  end if
end

on select me
  if the doubleClick then
    case pState of
      "1":
        pState = "0"
      otherwise:
        pState = "1"
    end case
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: pState])
  end if
  return 1
end
