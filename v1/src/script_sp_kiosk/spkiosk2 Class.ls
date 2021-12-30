property ancestor

on new me, tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData 
  ancestor = new(script("FUSEMember Class"), tName, tMemberPrefix, tMemberFigureType, tLocX, tLocY, tHeight, tDirection, lDimensions, spr, taltitude, pData)
  repeat while me.lSprites <= 1
    iSpr = getAt(1, count(me.lSprites))
    if spr <> iSpr then
      add(sprite(iSpr).scriptInstanceList, new(script("EventBroker Behavior"), spr))
    end if
  end repeat
  return(me)
end

on mouseDown me 
  userObj = sprite(getProp(gpObjects, gMyName)).getProp(#scriptInstanceList, 1)
  if (me.locY = userObj.locY) and (abs((me.locX - userObj.locX)) = 1) then
    openSplashKiosk()
  else
    callAncestor(#mouseDown, ancestor)
    sendFuseMsg("Move" && (me.locX + 1) && me.locY)
  end if
end
