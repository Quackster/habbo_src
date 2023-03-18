property sprBig, sprSmall, rightArrow

on mouseDown me
  sendSprite(sprSmall, #changePart, rightArrow)
  sendSprite(sprBig, #changePart, rightArrow)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #sprBig, [#comment: "Big sprite to send", #format: #integer, #default: 0])
  addProp(pList, #sprSmall, [#comment: "Small sprite to send", #format: #integer, #default: 0])
  addProp(pList, #rightArrow, [#comment: "is this a right arrow?", #format: #boolean, #default: 0])
  return pList
end
