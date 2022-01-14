on showprogram me, tMsg 
  if listp(tMsg) then
    tDst = tMsg.getAt(#show_dest)
    tCmd = tMsg.getAt(#show_command)
    tNum = tMsg.getAt(#show_params)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_" & tDst)
    if tSpr <> 0 then
      if (tCmd = "setfloor") then
        tSpr.member.paletteRef = member(getmemnum("chrome_floorpalette" & tNum))
      else
        if (tCmd = "fade") then
          tSpr.color = rgb("#" & tNum)
        end if
      end if
    else
      error(me, "Sprite not found:" && "show_" & tDst, #showprogram)
    end if
  end if
end
