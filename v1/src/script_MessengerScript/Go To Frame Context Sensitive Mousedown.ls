property sFrame, context

on mouseDown me
  if not voidp(sFrame) then
    goContext(sFrame, context)
  end if
end

on getPropertyDescriptionList me
  return [#sFrame: [#comment: "Marker", #format: #string, #default: EMPTY]]
end
