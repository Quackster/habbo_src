global gChosenStuffId, gChosenStuffType, gConfirmPopUp

on mouseUp me
  if gChosenStuffId contains "place" then
    return 
  end if
  member("confirm_title_e").text = "Confirm"
  member(getmemnum("wallAndFloor_confirm_txt_e")).text = "Are you absolutely sure you want" & RETURN & "to permanently delete this item?"
  gConfirmPopUp = new(script("PopUp Context Class"), 2000000000, 871, 887, point(0, 0))
  displayFrame(gConfirmPopUp, "deleteItem_confirm")
end
