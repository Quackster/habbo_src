property ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  repeat while me.lSprites <= tMemberPrefix
    iSpr = getAt(tMemberPrefix, tName)
    if spr <> iSpr then
      add(sprite(iSpr).scriptInstanceList, new(script("EventBroker Behavior"), spr))
    end if
  end repeat
  return(me)
end

on mouseDown me 
  userObj = sprite(getProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
  if me.locX = userObj.locX and abs(me.locY - userObj.locY) = 1 then
    openSplashKiosk()
  else
    callAncestor(#mouseDown, ancestor)
    sendFuseMsg("Move" && me.locX && me.locY + 1)
  end if
end
