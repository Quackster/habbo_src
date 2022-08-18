on beginSprite me 
  if (member(getmemnum("countryName")).text = "") then
    gConfirmPopUp = new(script("PopUp Context Class"), 2130000000, 851, 870, point(80, 80))
    displayFrame(gConfirmPopUp, "country")
  end if
end

on exitFrame me 
  go(the frame)
end
