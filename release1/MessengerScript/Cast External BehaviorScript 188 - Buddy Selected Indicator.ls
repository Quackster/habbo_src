property lineNum
global gpBuddyIndicators

on beginSprite me
  if voidp(gpBuddyIndicators) then
    gpBuddyIndicators = [:]
  end if
  l = getaProp(gpBuddyIndicators, lineNum)
  if voidp(l) then
    l = []
    addProp(gpBuddyIndicators, lineNum, l)
  end if
  add(l, me.spriteNum)
  disable(me)
end

on endSprite me
  sprite(me.spriteNum).visible = 1
  sprite(me.spriteNum).locH = 2000
  l = getaProp(gpBuddyIndicators, lineNum)
  deleteAt(l, getPos(l, me.spriteNum))
end

on enable me
  sprite(me.spriteNum).visible = 1
end

on disable me
  sprite(me.spriteNum).visible = 0
end

on getPropertyDescriptionList me
  return [#lineNum: [#comment: "Row", #format: #integer, #default: 1]]
end
