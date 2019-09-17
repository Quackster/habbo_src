property tvFrame, fireplaceOn, channelNumber, ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  polyfonfprand = 0
  if getaProp(me.pData, "CHANNEL") = "OFF" then
    fireplaceOn = 0
    return(me)
  end if
  fireplaceOn = 1
  channelNumber = integer(getaProp(me.pData, "CHANNEL"))
  return(me)
end

on updateStuffdata me, tProp, tValue 
  put(tProp, tValue)
  if tValue = "OFF" then
    fireplaceOn = 0
  else
    fireplaceOn = 1
    channelNumber = value(tValue)
  end if
end

on exitFrame me 
  tvFrame = tvFrame + 1
  if fireplaceOn and tvFrame mod 3 = 1 then
    mname = me.getPropRef(#lSprites, 3).member.name
    the itemDelimiter = "_"
    tmpName = ""
    tmpName = mname.getProp(#item, 1, mname.count(#item) - 1) & "_"
    the itemDelimiter = ","
    if channelNumber = 1 then
      newMName = tmpName & random(10)
    else
      if channelNumber = 2 then
        newMName = tmpName & 10 + random(5)
      else
        if channelNumber = 3 then
          newMName = tmpName & 15 + random(5)
        end if
      end if
    end if
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName)
    end if
  end if
  if fireplaceOn = 0 then
    newMName = "wood_tv_c_0_1_2_0_0"
    if getmemnum(newMName) > 0 then
      me.getPropRef(#lSprites, 3).castNum = getmemnum(newMName)
    end if
  end if
  me.getPropRef(#lSprites, 3).locZ = me.getPropRef(#lSprites, 2).locZ + 2
end

on setOn me 
  fireplaceOn = 1
  channelNumber = random(3)
  put("CHANNEL" && channelNumber)
  sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "CHANNEL" & "/" & channelNumber)
end

on setOff me 
  fireplaceOn = 0
  sendFuseMsg("SETSTUFFDATA /" & me.id & "/" & "CHANNEL" & "/" & "OFF")
end

on mouseDown me 
  callAncestor(#mouseDown, ancestor)
  if the doubleClick then
    if fireplaceOn = 1 then
      setOff(me)
    else
      setOn(me)
    end if
  end if
end
