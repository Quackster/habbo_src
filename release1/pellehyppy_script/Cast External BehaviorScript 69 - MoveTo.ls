property tX, tY

on mouseUp me
  sendFuseMsg("Move" && tX && tY)
  dontPassEvent()
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #tX, [#comment: "Move to X", #format: #integer, #default: 0])
  addProp(pList, #tY, [#comment: "Move to Y", #format: #integer, #default: 0])
  return pList
end
