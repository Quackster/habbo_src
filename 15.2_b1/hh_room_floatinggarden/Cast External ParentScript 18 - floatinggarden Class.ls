property pWaterFallFrame, pWaterFallSprite, pAnimTimer

on construct me
  pWaterFallFrame = 1
  pAnimTimer = 0
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on update me
  if pWaterFallSprite = VOID then
    return me.getAnimSprites()
  end if
  if the milliSeconds > (pAnimTimer + 200) then
    pAnimTimer = the milliSeconds
    pWaterFallFrame = pWaterFallFrame + 1
    if pWaterFallFrame > 4 then
      pWaterFallFrame = 1
    end if
    pWaterFallSprite.member = getMember("watersplash_" & pWaterFallFrame)
  end if
  return 1
end

on getAnimSprites me
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj <> 0 then
    pWaterFallSprite = tObj.getSprById("watersplash")
  end if
  return 1
end
