on exitFrame me
  global gEPIp, gEPPort, gpUiButtons
  clearGlobals()
  startTimer()
  gEPIp = "www.habbohotel.com"
  gEPPort = 37002
  gpUiButtons = [:]
  put " " into field "character_info_name"
  put " " into field "character_info_desc"
end
