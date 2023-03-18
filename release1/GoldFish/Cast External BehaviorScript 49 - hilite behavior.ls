property normalmember, hilitemember

on new me
  return me
end

on beginSprite me
  iSpr = me.spriteNum
  normalmember = (the member of sprite iSpr).name
  hilitemember = normalmember && "hi"
end

on mouseDown me
  iSpr = me.spriteNum
  set the member of sprite iSpr to hilitemember
end

on mouseUp me
  iSpr = me.spriteNum
  set the member of sprite iSpr to normalmember
end

on mouseEnter me
  iSpr = me.spriteNum
  put "mouseenter", normalmember, hilitemember
  if the mouseDown then
    set the member of sprite iSpr to hilitemember
  else
    set the member of sprite iSpr to normalmember
  end if
end

on mouseLeave me
  iSpr = me.spriteNum
  set the member of sprite iSpr to normalmember
end

on mouseUpOutSide me
  iSpr = me.spriteNum
  set the member of sprite iSpr to normalmember
end

on endSprite me
  iSpr = me.spriteNum
  set the member of sprite iSpr to normalmember
end
