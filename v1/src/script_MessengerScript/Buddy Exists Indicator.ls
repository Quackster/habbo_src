property lineNum
global gpBuddyExistsIndicators

on beginSprite me
  disable(me)
  if voidp(gpBuddyExistsIndicators) then
    gpBuddyExistsIndicators = [:]
  end if
  l = getaProp(gpBuddyExistsIndicators, lineNum)
  if voidp(l) then
    l = []
    addProp(gpBuddyExistsIndicators, lineNum, l)
  end if
  add(l, me.spriteNum)
  disable(me)
end

on endSprite me
  sprite(me.spriteNum).visible = 1
  sprite(me.spriteNum).locH = 2000
  l = getaProp(gpBuddyExistsIndicators, lineNum)
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
