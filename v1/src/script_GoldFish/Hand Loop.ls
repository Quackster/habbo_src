on exitFrame me 
  if objectp(hiliter) then
    hiliteExitframe(hiliter)
  end if
  go(the frame)
end

on mouseDown me 
  if objectp(hiliter) then
    mouseDown(hiliter)
  end if
end
