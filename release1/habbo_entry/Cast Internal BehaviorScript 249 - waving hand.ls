property spriteNum

on beginSprite me
  sprite(me.spriteNum).member = WhichMember_anim(me, #ls)
end

on WhichMember_anim me, whichPart
  global MyfigurePartList, MyfigureColorList
  oldDelim = the itemDelimiter
  the itemDelimiter = "_"
  anim = sprite(me.spriteNum).member.name.item[6]
  Acti = sprite(me.spriteNum).member.name.item[2]
  memName = "h_" & Acti & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & anim
  memNum = the number of member memName
  the itemDelimiter = oldDelim
  return memNum
end
