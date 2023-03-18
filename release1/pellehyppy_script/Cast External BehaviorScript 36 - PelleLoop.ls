on exitFrame me
  global hiliter, hiliteStart, gChosenStuffSprite, gPellePlayer
  if objectp(hiliter) then
    hiliteExitframe(hiliter)
  end if
  if voidp(gPellePlayer) = 0 then
    gPellePlayer.PlayerLoop()
  end if
  go(the frame)
end

on mouseDown me
  global hiliter
  if objectp(hiliter) then
    mouseDown(hiliter)
  end if
end
