property mag

on ChangePartPreviewSprite me, mem
  sprite(me.spriteNum).member = mem
  sprite(me.spriteNum).width = member(mem).width * mag
  sprite(me.spriteNum).height = member(mem).height * mag
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #mag, [#comment: "Give enlargement value", #format: #integer, #default: 0])
  return pList
end
