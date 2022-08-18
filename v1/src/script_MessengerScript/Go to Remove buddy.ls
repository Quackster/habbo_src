property num
global gChosenbuddyName

on mouseDown me
  name = gChosenbuddyName
  if not voidp(name) then
    s = member("removebuddytext").text
    put name into line 3 of s
    member("removebuddytext").text = s
    goContext("buddydelete")
  end if
end
