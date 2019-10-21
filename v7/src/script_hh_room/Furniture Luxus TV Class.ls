on prepare(me, tdata)
  tvFrame = 0
  polyfonfprand = 0
  formulaFrame = 0
  formulaMode = 0
  carLoop = 1
  stillPicture = 0
  stillWait = 0
  if tdata.getAt("FIREON") = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  exit
end

on update(me)
  if me.count(#pSprList) < 4 then
    return()
  end if
  tvFrame = not tvFrame
  if fireplaceOn and tvFrame = 1 then
    tName = member.name
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tTmpName = tName.getProp(#item, 1, tName.count(#item) - 1) & "_"
    the itemDelimiter = tDelim
    if carLoop = 1 then
      carLoopCount = random(7)
    end if
    if carLoop >= 1 then
      tNewName = tTmpName & formulaFrame
      formulaFrame = formulaFrame + 1
      if formulaFrame > 13 then
        formulaFrame = 1
        carLoop = carLoop + 1
        if carLoop >= carLoopCount then
          carLoop = 0
          stillPicture = random(2)
          stillWait = 50 + random(100)
          tvFrame = 0
        end if
      end if
    else
      if carLoop = 0 then
        if tvFrame <= stillWait then
          if stillPicture = 1 then
            if me.getPropRef(#pSprList, 1).skew = 180 then
              tNewName = tTmpName & 16
            else
              tNewName = tTmpName & 15
            end if
          else
            if stillPicture = 2 then
              tNewName = tTmpName & 14
            end if
          end if
        else
          carLoop = 1
        end if
      end if
    end if
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 4).castNum = tmember.number
      me.getPropRef(#pSprList, 4).width = tmember.width
      me.getPropRef(#pSprList, 4).height = tmember.height
    end if
  end if
  if fireplaceOn = 0 then
    tNewName = "tv_luxus_d_0_1_3_0_0"
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 4).castNum = tmember.number
      me.getPropRef(#pSprList, 4).width = tmember.width
      me.getPropRef(#pSprList, 4).height = tmember.height
    end if
  end if
  me.getPropRef(#pSprList, 4).locZ = me.getPropRef(#pSprList, 1).locZ + 2
  exit
end

on setOn(me)
  fireplaceOn = 1
  exit
end

on setOff(me)
  fireplaceOn = 0
  exit
end

on select(me)
  if the doubleClick then
    if fireplaceOn then
      tOnString = "OFF"
    else
      tOnString = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "FIREON" & "/" & tOnString)
  end if
  exit
end