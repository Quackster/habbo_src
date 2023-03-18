property fireplaceOn, polyfonfprand, formulaFrame, formulaMode, tvFrame, carLoop, carLoopCount, stillPicture, stillWait

on prepare me, tdata
  tvFrame = 0
  polyfonfprand = 0
  formulaFrame = 0
  formulaMode = 0
  carLoop = 1
  stillPicture = 0
  stillWait = 0
  if tdata["FIREON"] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me
  if me.pSprList.count < 4 then
    return 
  end if
  tvFrame = not tvFrame
  if fireplaceOn and (tvFrame = 1) then
    tName = me.pSprList[4].member.name
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tTmpName = tName.item[1..tName.item.count - 1] & "_"
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
            if me.pSprList[1].skew = 180 then
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
      me.pSprList[4].castNum = tmember.number
      me.pSprList[4].width = tmember.width
      me.pSprList[4].height = tmember.height
    end if
  end if
  if fireplaceOn = 0 then
    tNewName = "tv_luxus_d_0_1_3_0_0"
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.pSprList[4].castNum = tmember.number
      me.pSprList[4].width = tmember.width
      me.pSprList[4].height = tmember.height
    end if
  end if
  me.pSprList[4].locZ = me.pSprList[1].locZ + 2
end

on setOn me
  fireplaceOn = 1
end

on setOff me
  fireplaceOn = 0
end

on select me
  if the doubleClick then
    if fireplaceOn then
      tOnString = "OFF"
    else
      tOnString = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "FIREON" & "/" & tOnString)
  end if
end
