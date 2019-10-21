on showprogram(me, tMsg)
  if voidp(tMsg) then
    return(0)
  end if
  tThread = getThread(#room)
  if tThread = 0 then
    return(0)
  end if
  tRoomVis = tThread.getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return(0)
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tNum = tMsg.getAt(#show_params)
  tSpr = tRoomVis.getSprById("show_" & tDst)
  if not tSpr then
    return(error(me, "Sprite not found:" && "show_" & tDst, #showprogram))
  else
    if me = "setfloora" then
      member.paletteRef = member(getmemnum("clubfloorparta" & tNum))
    else
      if me = "setfloorb" then
        member.paletteRef = member(getmemnum("clubfloorpartb" & tNum))
      else
        if me = "setlamp" then
          member.paletteRef = member(getmemnum("lattialamppu" & tNum))
        end if
      end if
    end if
  end if
  exit
end