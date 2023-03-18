on mouseUp me
  if the runMode = "Author" then
    go(1)
  end if
  gotoNetPage(the moviePath & the movieName)
  dontPassEvent()
end
