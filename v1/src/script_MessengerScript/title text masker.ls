on beginSprite me 
  iSpr = me.spriteNum
  titletext = sprite((iSpr + 1)).undefined
  if (member(titletext).type = #field) or (member(titletext).type = #text) then
    textwidth = getAt(charPosToLoc(member(titletext), member(titletext).text.length), 1)
    sprite(iSpr).width = (textwidth + 20)
    sprite((iSpr + 1)).locH = ((sprite(iSpr).locH - (textwidth / 2)) - 3)
  end if
end
