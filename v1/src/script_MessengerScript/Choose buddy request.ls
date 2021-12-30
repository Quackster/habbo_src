on mouseUp me 
  mline = the mouseLine
  
  if mline > 0 then
    gChosenBuddyRequest = null
    field(0).textStyle = "underline"
  end if
end
