property PlastoCodeModel, sFrame, context

on mouseDown me 
  gPlastoCodeModel = PlastoCodeModel
  sendSprite(gPlastoCodeSpr, #updateCode)
  goContext(sFrame, context)
end

on getPropertyDescriptionList me 
  return([#sFrame:[#comment:"Marker", #format:#string, #default:""], #PlastoCodeModel:[#comment:"PlastoCodeModel", #format:#string, #default:"E"]])
end
