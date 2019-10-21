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
  if the milliSeconds < (pDiscoTimer + 500) then
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
  tDst = "df" & random(3)
  tCmd = "setfloor" & ["a", "b"].getAt(random(2))
  tNum = string(random(12))
  tSpr = tRoomVis.getSprById("show_" & tDst)
  if not tSpr then
    return(error(me, "Sprite not found:" && "show_" & tDst, #showprogram))
  else
    if (tCmd = "setfloora") then
      tSpr.member.paletteRef = member(getmemnum("clubfloorparta" & tNum))
    else
      if (tCmd = "setfloorb") then
        tSpr.member.paletteRef = member(getmemnum("clubfloorpartb" & tNum))
      end if
    end if
  end if
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return FALSE
  end if
  tThread = getThread(#room)
  if (tThread = 0) then
    return FALSE
  end if
  tRoomVis = tThread.getInterface().getRoomVisualizer()
  if (tRoomVis = 0) then
    return FALSE
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tNum = tMsg.getAt(#show_params)
  tSpr = tRoomVis.getSprById("show_" & tDst)
  if not tSpr then
    return(error(me, "Sprite not found:" && "show_" & tDst, #showprogram))
  else
    if (tCmd = "setlamp") then
      tSpr.member.paletteRef = member(getmemnum("lattialamppu" & tNum))
    end if
  end if
end
