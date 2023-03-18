property command

on mouseUp me
  sendFuseMsg(command)
end

on getPropertyDescriptionList me
  return [#command: [#comment: "Komento", #default: EMPTY, #format: #string]]
end

on mouseEnter me
  if command = "GOAWAY" then
    helpText_setText(AddTextToField("GoAway"))
  end if
end

on mouseLeave me
  if command = "GOAWAY" then
    helpText_empty(AddTextToField("GoAway"))
  end if
end
