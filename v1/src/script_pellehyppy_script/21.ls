property pMyName

on SpriteNumOfSprite me, whichName 
  if whichName = pMyName then
    return(me.spriteNum)
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #pMyName, [#comment:"Sprite identification name", #format:#string, #default:""])
  return(pList)
end
