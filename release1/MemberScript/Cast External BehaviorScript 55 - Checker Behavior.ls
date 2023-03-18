property f, checked

on beginSprite me
  check(me, checked)
end

on check me, b
  checked = b
  s = member(the member of sprite me.spriteNum).name
  set the member of sprite the spriteNum of me to word 1 of s && b
  if b then
    put "true" into field f
  else
    put "false" into field f
  end if
end

on mouseDown me
  check(me, not checked)
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #checked, [#comment: "Checked?", #format: #boolean, #default: 1])
  addProp(pList, #f, [#comment: "field", #format: #string, #default: "x"])
  return pList
end
