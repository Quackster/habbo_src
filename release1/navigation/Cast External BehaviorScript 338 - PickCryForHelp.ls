on mouseUp me
  global CryHelp, CryCount
  sendEPFuseMsg("PICK_CRYFORHELP" && CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("url"))
end
