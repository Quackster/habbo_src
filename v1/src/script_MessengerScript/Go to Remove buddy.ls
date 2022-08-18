on mouseDown me 
  name = gChosenbuddyName
  if not voidp(name) then
    s = member("removebuddytext").text
    member("removebuddytext").text = s
    goContext("buddydelete")
  end if
end
