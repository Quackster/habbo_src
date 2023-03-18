property theField
global gMyName

on mouseDown me
  sendEPFuseMsg("GETORDERINFO /" & member(theField).text && gMyName)
end

on getPropertyDescriptionList me
  return [#theField: [#comment: "Field where to get the code:", #format: #string, #default: EMPTY]]
end
