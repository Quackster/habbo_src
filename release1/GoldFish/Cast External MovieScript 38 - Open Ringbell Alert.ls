global gRingBell

on openRingbellAlert user
  gRingBell = new(script("PopUp Context Class"), 2000000000, 871, 881, point(0, 0))
  member("ringbell.user").text = user
  displayFrame(gRingBell, "ringbell")
end

on closeRingbellAlert
  close(gRingBell)
end

on letUserIn
  sendFuseMsg("LETUSERIN" && member("ringbell.user").text)
  closeRingbellAlert()
end
