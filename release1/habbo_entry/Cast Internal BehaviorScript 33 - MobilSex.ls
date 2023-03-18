property sex, mysex, init, isChange

on beginSprite me
  if isChange = 1 then
    mysex = field("charactersex_field")
    sendAllSprites(#mobileSexChange, mysex)
    put "MY SEX IS" && mysex
  else
    if sex = "Female" then
      put sex into field "charactersex_field"
      sendAllSprites(#mobileSexChange, sex)
    end if
  end if
end

on mouseDown me
  sendAllSprites(#mobileSexChange, sex)
end

on mobileSexChange me, tsex
  if tsex = sex then
    set the member of sprite the spriteNum of me to "radio_on_btn"
  else
    set the member of sprite the spriteNum of me to "radio_off_btn"
  end if
  init = 1
  put tsex into field "charactersex_field"
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #sex, [#comment: "Sex sex", #range: ["Male", "Female"], #format: #string, #default: "Male"])
  addProp(pList, #isChange, [#comment: "is this properties change frame", #format: #boolean, #default: 0])
  return pList
end
