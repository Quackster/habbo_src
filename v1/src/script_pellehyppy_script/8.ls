property s

on exitFrame me 
  if gKeyAcceptTime = void() then
    if gKeycounter = void() then
      gKeycounter = 0
    end if
    gKeyAcceptTime = the milliSeconds - 22
  end if
  if the milliSeconds > gKeyAcceptTime then
    gKeycounter = gKeycounter + 1
    if gKeycounter < s.length then
      if s.getProp(#char, gKeycounter) <> "0" then
        goJumper.MykeyDown(s.getProp(#char, gKeycounter))
      else
        NotKeyDown(goJumper)
      end if
      gKeyAcceptTime = the milliSeconds + 10
    else
      if the controlDown then
        go("jumpingplace")
      end if
    end if
  end if
  go(the frame)
end
