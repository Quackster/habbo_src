on exitFrame me
  global gEPIp, gEPPort, gpUiButtons, gStartLoadingTime, gEndLoadingTime, gHabboRep, gCountryPrefix
  t1 = gStartLoadingTime
  t2 = gEndLoadingTime
  clearGlobals()
  startTimer()
  gCountryPrefix = "gf"
  gStartLoadingTime = t1
  gEndLoadingTime = t2
  gEPIp = "fuse-pc2.kultakalaglobal.com"
  gEPPort = 37050
  if (the runMode <> "Author") then
    gHabboRep = getNetText("http://habborep.magenta.net/serverid.txt")
    hostInfo = externalParamValue("swText")
    if (not voidp(hostInfo) and (length(hostInfo) > 8)) then
      gEPIp = char 1 to (offset(":", hostInfo) - 1) of hostInfo
      gEPPort = integer(char (offset(":", hostInfo) + 1) to length(hostInfo) of hostInfo)
    else
    end if
  end if
  if the optionDown then
    the alertHook = 0
    alert(((gEPIp & " --- ") & gEPPort))
  end if
  tellStreamStatus(0)
  gpUiButtons = [:]
  put " " into field "character_info_name"
  put " " into field "character_info_desc"
  member("habbo_credits").text = "[Loading credits]"
  member("credits_amount_e").text = "[Loading credits]"
  ResetNavigationWindow()
end
