property sprBig, sprSmall, rightArrow

on mouseDown me
  sendSprite(sprSmall, #changeColor, rightArrow)
  sendSprite(sprBig, #changeColor, rightArrow)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #sprBig, [#comment: "Big sprite to send", #format: #integer, #default: 0])
  addProp(pList, #rightArrow, [#comment: "is this a right arrow?", #format: #boolean, #default: 0])
  return pList
end
