on beginSprite me 
  iSpr = me.spriteNum
  sprite(sprite(0).number).cursor = ["cursor_finger_mask", sprite(0).number]
  sprite(me.spriteNum).member = WhichMember(#hd)
  sprite((me.spriteNum + 1)).member = WhichMember(#fc)
  sprite((me.spriteNum + 2)).member = WhichMember(#ey)
  sprite((me.spriteNum + 3)).member = WhichMember(#hr)
  sprite(me.spriteNum).bgColor = getaProp(MyfigureColorList, #bd)
  sprite((me.spriteNum + 1)).bgColor = getaProp(MyfigureColorList, #fc)
  sprite((me.spriteNum + 2)).bgColor = getaProp(MyfigureColorList, #ey)
  sprite((me.spriteNum + 3)).bgColor = getaProp(MyfigureColorList, #hr)
end

on endSprite me 
  iSpr = me.spriteNum
  sprite(iSpr).cursor = 0
end

on WhichMember whichPart 
  memName = "h_" & "std" & "_" & string(whichPart) & "_" & getaProp(MyfigurePartList, whichPart) & "_" & "3" & "_" & 0
  memNum = getmemnum(memName)
  return(memNum)
end

on mouseUp  
  dancing = not dancing
  sendFuseMsg("STOP CarryDrink")
  if dancing then
    sendFuseMsg("Dance")
  else
    sendFuseMsg("STOP Dance")
  end if
end
