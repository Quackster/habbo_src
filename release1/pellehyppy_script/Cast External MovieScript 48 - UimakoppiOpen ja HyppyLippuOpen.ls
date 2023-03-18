global gPopUpContext, gMessengerPlace, gMessengerLastLoc

on openuimakoppi
  if objectp(gPopUpContext) then
    close(gPopUpContext)
  end if
  if not (the movieName contains "entry") then
    gPopUpContext = new(script("PopUp Context Class"), 2110000000, 660, 710, point(0, 0))
  else
    gPopUpContext = new(script("PopUp Context Class"), 2110000000, 380, 430, point(0, 0))
  end if
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  displayFrame(gPopUpContext, "uimakoppi")
end

on closeUimaKoppi
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  close(gPopUpContext)
end

on openHyppylippu
  if the movieName contains "pellehyppy" then
    if objectp(gPopUpContext) then
      close(gPopUpContext)
    end if
    if not (the movieName contains "entry") then
      gPopUpContext = new(script("PopUp Context Class"), 2110000000, 660, 710, point(0, 0))
    else
      gPopUpContext = new(script("PopUp Context Class"), 2110000000, 380, 430, point(0, 0))
    end if
    if the movieName contains "entry" then
      spr1 = 381
    else
      spr1 = 661
    end if
    if value(member("JumpTICKETS").text) > 0 then
      tMem = member("hyppylippu_text")
      tMem.lineHeight = 10
      tMem.text = RETURN
      tMem.text = tMem.text & "Each ticket entitles you to 1 dive. "
      tMem.text = tMem.text & "You get 10 tickets for 5 Habbo Credits. "
      tMem.text = tMem.text & "You do not have to use all of your "
      tMem.text = tMem.text & "tickets at once - they will remain "
      tMem.text = tMem.text & "valid for your next visit to the Habbo Lido. "
      tMem.text = tMem.text & "You can also buy tickets for other Habbos "
      tMem.text = tMem.text & "if you want. Join the queue in front of the "
      tMem.text = tMem.text & "elevators once you have bought your tickets..." & RETURN & RETURN
      tMem.text = tMem.text & "You currently have" && member("JumpTICKETS").text && "tickets"
    else
      tMem = member("hyppylippu_text")
      tMem.lineHeight = 10
      tMem.text = RETURN
      tMem.text = tMem.text & "Each ticket entitles you to 1 dive. "
      tMem.text = tMem.text & "You get 10 tickets for 5 Habbo Credits. "
      tMem.text = tMem.text & "You do not have to use all of your "
      tMem.text = tMem.text & "tickets at once - they will remain "
      tMem.text = tMem.text & "valid for your next visit to the Habbo Lido. "
      tMem.text = tMem.text & "You can also buy tickets for other Habbos "
      tMem.text = tMem.text & "if you want. Join the queue in front of the "
      tMem.text = tMem.text & "elevators once you have bought your tickets..." & RETURN & RETURN
      tMem.text = tMem.text & "You currently have no tickets"
    end if
    displayFrame(gPopUpContext, "hyppylippu")
  end if
end

on closeHyppylippu
  if the movieName contains "entry" then
    spr1 = 381
  else
    spr1 = 661
  end if
  close(gPopUpContext)
end
