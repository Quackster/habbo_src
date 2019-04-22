on construct(me)
  receiveUpdate(me.getID())
  return(1)
  exit
end

on deconstruct(me)
  releaseSprite(pSpr.spriteNum)
  removeUpdate(me.getID())
  return(1)
  exit
end

on update(me)
  if voidp(pKeyAcceptTime) then
    pKeyAcceptTime = the milliSeconds - 101
  end if
  if the milliSeconds >= pKeyAcceptTime then
    if the keyPressed <> "" then
      me.MykeyDown(the key, the milliSeconds - pKeyAcceptTime)
    else
      me.NotKeyDown(the milliSeconds - pKeyAcceptTime)
    end if
    pKeyAcceptTime = the milliSeconds + 100 - the milliSeconds - pKeyAcceptTime
  end if
  exit
end