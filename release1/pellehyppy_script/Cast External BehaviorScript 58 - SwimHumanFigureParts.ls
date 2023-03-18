property part
global MyfigurePartList, MyfigureColorList, figurePartList, figureColorList

on beginSprite me
  if part = "hr" then
    mem = WhichMember(part)
    sprite(me.spriteNum).member = mem
    sprite(me.spriteNum).width = member(mem).width * 4
    sprite(me.spriteNum).height = member(mem).height * 4
  end if
  sprite(me.spriteNum).bgColor = getaProp(MyfigureColorList, part)
end

on WhichMember whichPart
  global MyfigurePartList, MyfigureColorList
  memName = "sh_" & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "2" & "_" & 0
  memNum = the number of member memName
  return memNum
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #part, [#comment: "Give part", #format: #string, #default: "ch"])
  return pList
end
