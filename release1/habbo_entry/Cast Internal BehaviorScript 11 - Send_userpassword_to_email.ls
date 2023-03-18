on mouseUp me
  global gEPConnectionInstance
  put 
  put gEPConnectionInstance
  if field("NameCheck") <> EMPTY then
    put "SEND_USERPASS_TO_EMAIL " & field("NameCheck")
    sendEPFuseMsg("SEND_USERPASS_TO_EMAIL " & field("NameCheck") && field("EmailCheckField"))
  end if
  go(the frame + 1)
end
