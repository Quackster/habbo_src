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
  if me.count(#pSprList) < 3 then
    return(0)
  end if
  pState = tValue
  if me = "1" then
    me.switchMember("c", "0")
    me.getPropRef(#pSprList, 3).visible = 1
  else
    if me = "2" then
      me.switchMember("c", "1")
      me.getPropRef(#pSprList, 3).visible = 1
    else
      me.getPropRef(#pSprList, 3).visible = 0
    end if
  end if
  return(1)
  exit
end

on switchMember(me, tPart, tNewMem)
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  if me.count(#pSprList) < tSprNum or tSprNum = 0 then
    return(0)
  end if
  tName = member.name
  tName = tName.getProp(#char, 1, tName.length - 1) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  return(1)
  exit
end

on select(me)
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if not tUserObj then
      return(1)
    end if
    if abs(tUserObj.pLocX - me.pLocX) > 1 or abs(tUserObj.pLocY - me.pLocY) > 1 then
      return(1)
    end if
    if me = "0" then
      pState = "1"
    else
      if me = "1" then
        pState = "2"
      else
        pState = "0"
      end if
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:pState])
  end if
  return(1)
  exit
end