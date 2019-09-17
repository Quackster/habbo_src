on mouseUp me 
  if "room_password_check" <> field(0) and getaProp(gProps, #doorMode) = #password then
    goContext("pw_no_match")
  else
    reserveRoom()
    goContext("confirm")
  end if
end
