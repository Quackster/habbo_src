property s
global goJumper, gKeyAcceptTime, gKeycounter

on exitFrame me
  if gKeyAcceptTime = VOID then
    if gKeycounter = VOID then
      gKeycounter = 0
    end if
    gKeyAcceptTime = the milliSeconds - 22
  end if
  if the milliSeconds > gKeyAcceptTime then
    gKeycounter = gKeycounter + 1
    if gKeycounter < s.length then
      if s.char[gKeycounter] <> "0" then
        goJumper.MykeyDown(s.char[gKeycounter])
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
