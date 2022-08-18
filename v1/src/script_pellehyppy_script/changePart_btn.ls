property pWhichPart, pChangeBtnDir

on beginSprite me 
end

on mouseUp me 
  sendAllSprites(#changePart, pWhichPart, pChangeBtnDir)
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #pWhichPart, [#comment:"Which figure part you want change", #format:#string, #default:""])
  addProp(pList, #pChangeBtnDir, [#comment:"Direction 1/-1", #format:#integer, #default:1])
  return(pList)
end
