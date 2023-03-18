property context

on mouseDown me
  global gSplashKioskOpenTime, gpSplashSubmitted
  duration = the ticks - gSplashKioskOpenTime
  if gpSplashSubmitted then
    status = 1
  else
    status = 0
  end if
  sendEPFuseMsg("KIOSKEVENT /splash/" & duration / 30 & "/" & status)
  close(context)
end
