on exitFrame me 
  if (gKeyAcceptTime = void()) then
    gKeyAcceptTime = (the milliSeconds - 101)
  end if
  if the milliSeconds >= gKeyAcceptTime then
    if the keyPressed <> "" then
      goJumper.MykeyDown(the key, (the milliSeconds - gKeyAcceptTime))
    else
      goJumper.NotKeyDown((the milliSeconds - gKeyAcceptTime))
    end if
    gKeyAcceptTime = (the milliSeconds + (100 - (the milliSeconds - gKeyAcceptTime)))
  end if
  go(the frame)
end
