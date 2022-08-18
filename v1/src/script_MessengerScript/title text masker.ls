on beginSprite me
  iSpr = me.spriteNum
  titletext = the member of sprite (iSpr + 1)
  if ((member(titletext).type = #field) or (member(titletext).type = #text)) then
    textwidth = getAt(charPosToLoc(member(titletext), member(titletext).text.length), 1)
    set the width of sprite iSpr to (textwidth + 20)
    set the locH of sprite (iSpr + 1) to ((sprite(iSpr).locH - (textwidth / 2)) - 3)
  end if
end
