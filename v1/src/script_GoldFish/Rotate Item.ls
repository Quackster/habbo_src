property direction
global gChosenStuffId, gChosenStuffSprite

on mouseDown me
  sendSprite(gChosenStuffSprite, #rotate, direction)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #direction, [#comment: "Direction", #default: 2, #format: #integer])
  return pList
end
