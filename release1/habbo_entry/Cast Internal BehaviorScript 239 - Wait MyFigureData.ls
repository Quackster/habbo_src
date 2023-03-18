on exitFrame me
  global MyfigureColorList, MyfigurePartList
  if (MyfigureColorList <> VOID) and (MyfigurePartList <> VOID) then
    go(the frame + 1)
  end if
  go(the frame)
end
