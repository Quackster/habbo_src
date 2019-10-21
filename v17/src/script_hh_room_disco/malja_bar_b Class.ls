property pDiscoTimer

on construct me 
  pDiscoTimer = 0
  return TRUE
end

on deconstruct me 
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on update me 
  if the milliSeconds < (pDiscoTimer + 1000) then
    return TRUE
  end if
  pDiscoTimer = the milliSeconds
  tThread = getThread(#room)
  if (tThread = 0) then
    return FALSE
  end if
  tRoomVis = tThread.getInterface().getRoomVisualizer()
  if (tRoomVis = 0) then
    return FALSE
  end if
  tNum = string(random(7))
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_discofloor")
  if tSpr <> 0 then
    tSpr.member.paletteRef = member(getmemnum("chrome_floorpalette" & tNum))
  else
    error(me, "Sprite not found:" && "show_discofloor", #showprogram)
  end if
end

on showprogram me, tMsg 
  if listp(tMsg) then
    tDst = tMsg.getAt(#show_dest)
    tCmd = tMsg.getAt(#show_command)
    tNum = tMsg.getAt(#show_params)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_" & tDst)
    if tSpr <> 0 then
      if (tCmd = "fade") then
        tSpr.color = rgb("#" & tNum)
      end if
    else
      error(me, "Sprite not found:" && "show_" & tDst, #showprogram)
    end if
  end if
end
