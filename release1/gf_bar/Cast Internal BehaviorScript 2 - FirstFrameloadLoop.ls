on exitFrame
  global gLoader
  if gLoader <> VOID then
    gLoader.LoaderLoop()
  end if
  put "LOADLOOP" && the frame
  if the runMode <> "Author" then
    go(the frame)
  end if
end
