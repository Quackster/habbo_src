global gPopUpContext2, gUnits, gRefreshNavi

on exitFrame me
  if gUnits <> VOID then
    if gPopUpContext2 <> VOID then
      go(the frame + 1)
      exit
    end if
    if (gPopUpContext2 = VOID) and (gUnits.count > 0) then
      gRefreshNavi = 1
      openNavigator()
      go(the frame + 1)
      exit
    end if
  end if
  go(the frame)
end
