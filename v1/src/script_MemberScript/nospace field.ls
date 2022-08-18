on keyDown me
  put the keyCode
  if ((the keyCode <> 49) and (the keyCode <> 36)) then
    pass()
  end if
end
