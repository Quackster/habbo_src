global gMyName

on beginSprite me
  member("ticket_owner_field").text = gMyName
end

on mouseUp me
  tCustomerName = gMyName
  if member("ticket_owner_field").text <> EMPTY then
    tCustomerName = member("ticket_owner_field").text
  end if
  sendEPFuseMsg("PURCHASE /a2 hyppy" && tCustomerName)
  dontPassEvent()
end

on endSprite me
  member("ticket_owner_field").text = EMPTY
end
