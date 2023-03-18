on exitFrame me
  if netDone() then
    initCore()
  else
    go(the frame)
  end if
end
