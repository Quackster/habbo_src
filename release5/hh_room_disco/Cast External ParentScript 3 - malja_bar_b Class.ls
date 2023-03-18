on showprogram me, tMsg
  if listp(tMsg) then
    tDst = tMsg[#show_dest]
    tCmd = tMsg[#show_command]
    tNum = tMsg[#show_params]
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_" & tDst)
    if tSpr <> 0 then
      case tCmd of
        "setfloor":
          tSpr.member.paletteRef = member(getmemnum("chrome_floorpalette" & tNum))
        "fade":
          tSpr.color = rgb("#" & tNum)
      end case
    else
      error(me, "Sprite not found:" && "show_" & tDst, #showprogram)
    end if
  end if
end
