property pTrackingURL

on construct me 
  pTrackingURL = getVariable("stats.tracking.url")
  if (pTrackingURL = 0) or (pTrackingURL = "") then
    error(me, "Stats tracking URL not found!", #construct)
  end if
  registerListener(getVariable("connection.info.id", #info), me.getID(), [166:#updateStats])
  return TRUE
end

on deconstruct me 
  unregisterListener(getVariable("connection.info.id", #info), me.getID(), [166:#updateStats])
  return TRUE
end

on updateStats me, tMsg 
  tNetThing = replaceChunks(pTrackingURL, "\\TCODE", tMsg.content)
  if (pTrackingURL.ilk = #string) then
    preloadNetThing(tNetThing)
  end if
end
