on construct me
  me.pTimeoutUpdates = 1
  return 1
end

on Initialize me
  me.setActiveFlag(1)
  me.registerForIGComponentUpdates("GameList")
end

on pollContentUpdate me, tForced
  tMainThread = me.getMainThread()
  if tMainThread = 0 then
    return 0
  end if
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if not tService.isUpdateTimestampExpired() then
    return 0
  end if
  tService.pollContentUpdate(1)
end
