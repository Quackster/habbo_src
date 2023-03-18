on mouseUp me
  if the movieName contains "private" then
    sendFuseMsg("GETSTRIP new")
  end if
end

on mouseEnter me
  if the movieName contains "private" then
    helpText_setText(AddTextToField("ShowHand"))
  else
    helpText_setText(AddTextToField("HandWorksOnlyYourOwnRoom"))
  end if
end

on mouseLeave me
  if the movieName contains "private" then
    helpText_empty(AddTextToField("ShowHand"))
  else
    helpText_empty(AddTextToField("HandWorksOnlyYourOwnRoom"))
  end if
end
