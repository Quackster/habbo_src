on exitFrame
  global gChosenUnitIp, gChosenUnitPort, gLang, gEPIp, gEPPort
  forget(window("goldfish_Messenger"))
  gLang = "f"
  gChosenUnitPort = 40201
  gChosenUnitIp = "fuse.taivas.com"
  gEPIp = "fuse.taivas.com"
  gEPPort = 40288
  init()
end
