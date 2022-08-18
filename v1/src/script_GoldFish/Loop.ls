on exitFrame me
  global hiliter, hiliteStart, gChosenStuffSprite
  if ((the ticks - hiliteStart) > 220) then
    if not voidp(gChosenStuffSprite) then
      sendSprite(gChosenStuffSprite, #unhilite)
    end if
  end if
  if objectp(hiliter) then
    hiliteExitframe(hiliter)
  end if
  go(the frame)
end

on mouseDown me
  global hiliter
  if objectp(hiliter) then
    mouseDown(hiliter)
  end if
end
