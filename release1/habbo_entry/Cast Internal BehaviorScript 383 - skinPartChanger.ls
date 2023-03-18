property parts, sprs, sprto

on beginSprite me
  sendSprite(sprto, #addExtraParts, parts, sprs)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #sprto, [#comment: "Sprite to send", #format: #integer, #default: 130])
  addProp(pList, #parts, [#comment: "ExtraParts", #format: #string, #default: "lh,bd,rh"])
  addProp(pList, #sprs, [#comment: "their sprite numbers", #format: #string, #default: "138,127,137"])
  return pList
end
