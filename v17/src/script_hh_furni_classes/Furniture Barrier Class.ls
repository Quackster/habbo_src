on prepare(me, tdata)
  me.setState(tdata.getAt(#stuffdata))
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  me.setState(tValue)
  exit
end

on setState(me, tValue)
  if me.count(#pSprList) < 5 then
    return(0)
  end if
  pBlinkCounter = 0
  pState = tValue
  me.getPropRef(#pSprList, 5).visible = pState = "1"
  return(1)
  exit
end

on update(me)
  if pState <> "1" then
    return(1)
  end if
  if me.count(#pSprList) < 5 then
    return(0)
  end if
  if pBlinkCounter = 0 then
    me.getPropRef(#pSprList, 5).visible = 1
  end if
  if pBlinkCounter = 20 then
    me.getPropRef(#pSprList, 5).visible = 0
  end if
  pBlinkCounter = pBlinkCounter + 1
  if pBlinkCounter > 45 then
    pBlinkCounter = 0
  end if
  exit
end

on select(me)
  if the doubleClick then
    if me = "1" then
      pState = "0"
    else
      pState = "1"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:pState])
  end if
  return(1)
  exit
end