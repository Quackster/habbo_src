global gUnits, gDoor, gChosenUnitIp, gChosenUnitPort, gNaviP, ClickPlace, ClickPlaceNum, gPopUpContext2, gNaviWindowsSpr

on mouseWithin me
  if (the mouseDown and rollover(me.spriteNum)) then
    if voidp(gUnits) then
      return 
    end if
    if ((ClickPlace.getaProp("Main") = 1) and (ClickPlace.getaProp("Multiroom") = 1)) then
      unitName = gNaviP.getPropAt(ClickPlaceNum)
      gDoor = 0
    else
      if (ClickPlace.getaProp("Main") <> 1) then
        unitName = ClickPlace.getaProp("Main")
        gDoor = ((gNaviP.findPos(gNaviP.getPropAt(ClickPlaceNum)) - gNaviP.findPos(unitName)) - 1)
        if (gDoor < 0) then
          gDoor = 0
        end if
      else
        unitName = gNaviP.getPropAt(ClickPlaceNum)
        gDoor = 0
      end if
    end if
    unit = gUnits.getaProp(unitName)
    put (("GoButton" && "UnitName") && unitName), gDoor
    if (unit <> VOID) then
      host = gUnits.getaProp(unitName).getaProp("host")
      gChosenUnitIp = char (offset("/", host) + 1) to host.length of host
      gChosenUnitPort = gUnits.getaProp(unitName).getaProp("port")
      put host, gChosenUnitIp, gChosenUnitPort
      if rollover(me.spriteNum) then
        gNaviWindowsSpr = 0
        member("LoadPublicRoom").text = ((AddTextToField("LoadingPublicRoom") & RETURN) & unitName)
        sFrame = "loading_public"
        goContext(sFrame, gPopUpContext2)
        updateStage()
        gPopUpContext2 = VOID
        goUnit(gUnits.getaProp(unitName).getaProp("name"), gDoor)
      end if
    end if
  end if
end
