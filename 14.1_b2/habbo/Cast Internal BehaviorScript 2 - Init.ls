on exitFrame me
  if netDone() then
    startClient()
  else
    go(the frame)
  end if
end
