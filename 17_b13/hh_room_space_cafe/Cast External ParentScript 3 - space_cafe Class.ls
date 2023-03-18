on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tThread = getThread(#room)
  if tThread = 0 then
    return 0
  end if
  tRoomVis = tThread.getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tNum = tMsg[#show_params]
  tSpr = tRoomVis.getSprById("show_" & tDst)
  if not tSpr then
    return error(me, "Sprite not found:" && "show_" & tDst, #showprogram)
  else
    case tCmd of
      "visible":
        tSpr.member.paletteRef = member(getmemnum("flipboard" & tNum))
      "litecol":
        tSpr.member.paletteRef = member(getmemnum("maglit" & tNum))
      "ufol":
        tSpr.member.paletteRef = member(getmemnum("ufolamp" & tNum))
    end case
  end if
end
