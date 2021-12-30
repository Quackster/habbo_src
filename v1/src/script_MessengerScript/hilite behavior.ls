property normalmember, hilitemember

on new me 
  return(me)
end

on beginSprite me 
  iSpr = me.spriteNum
  normalmember = sprite(iSpr).undefined.name
  hilitemember = normalmember && "hi"
end

on mouseDown me 
  iSpr = me.spriteNum
  sprite(iSpr).undefined = hilitemember
end

on mouseUp me 
  iSpr = me.spriteNum
  sprite(iSpr).undefined = normalmember
end

on mouseEnter me 
  iSpr = me.spriteNum
  put("mouseenter", normalmember, hilitemember)
  if the mouseDown then
    sprite(iSpr).undefined = hilitemember
  else
    sprite(iSpr).undefined = normalmember
  end if
end

on mouseLeave me 
  iSpr = me.spriteNum
  sprite(iSpr).undefined = normalmember
end

on mouseUpOutSide me 
  iSpr = me.spriteNum
  sprite(iSpr).undefined = normalmember
end

on endSprite me 
  iSpr = me.spriteNum
  sprite(iSpr).undefined = normalmember
end
