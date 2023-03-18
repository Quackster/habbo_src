global gChosenBuddyRequest

on mouseUp me
  mline = the mouseLine
  set the textStyle of field "buddyrequests" to "plain"
  if mline > 0 then
    gChosenBuddyRequest = line mline of field "buddyrequests"
    set the textStyle of line mline of field "buddyrequests" to "underline"
  end if
end
