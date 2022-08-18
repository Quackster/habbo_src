property sFrame, PlastoCodeModel, context

on mouseDown me
  global gPlastoCodeModel, gPlastoCodeSpr
  gPlastoCodeModel = PlastoCodeModel
  sendSprite(gPlastoCodeSpr, #updateCode)
  goContext(sFrame, context)
end

on getPropertyDescriptionList me
  return [#sFrame: [#comment: "Marker", #format: #string, #default: EMPTY], #PlastoCodeModel: [#comment: "PlastoCodeModel", #format: #string, #default: "E"]]
end
