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
    if (tCmd = "visible") then
      tSpr.member.paletteRef = member(getmemnum("flipboard" & tNum))
    else
      if (tCmd = "litecol") then
        tSpr.member.paletteRef = member(getmemnum("maglit" & tNum))
      else
        if (tCmd = "ufol") then
          tSpr.member.paletteRef = member(getmemnum("ufolamp" & tNum))
        end if
      end if
    end if
  end if
end
