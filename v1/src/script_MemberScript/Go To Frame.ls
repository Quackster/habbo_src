property sFrame

on mouseUp me
  gotoFrame(sFrame)
end

on getPropertyDescriptionList me
  return [#sFrame: [#comment: "Marker", #format: #string, #default: EMPTY]]
end
