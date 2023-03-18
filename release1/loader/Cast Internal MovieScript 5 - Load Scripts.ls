global gLoadNo, gCurrentNetIds, gCurrentFile, gBytes, gLastF, gStartLoadingTime, gEndLoadingTime

on startLoading
  gLoadNo = 0
  gLastF = 0
  gBytes = 0
  gStartLoadingTime = the milliSeconds
  gCurrentNetIds = []
  updateBar()
  nextLoad()
  nextLoad()
end

on nextLoad
  gLoadNo = gLoadNo + 1
  if gLoadNo <= the number of lines in field "loadlist" then
    file = line gLoadNo of field "loadlist"
    if the runMode = "Author" then
      file = "http://www.habbohotel.com/dcr/dcr2505/" & file
    end if
    add(gCurrentNetIds, [preloadNetThing(file), 0, file, the milliSeconds])
    put file
  else
    if gCurrentNetIds.count = 0 then
      loadComplete()
    end if
  end if
end

on loadComplete
  gLastF = 1.0
  updateBar()
  gEndLoadingTime = the milliSeconds
  go("ok")
end

on checkload
  repeat with i = count(gCurrentNetIds) down to 1
    netId = gCurrentNetIds[i][1]
    l = getStreamStatus(netId)
    if listp(l) then
      bs = getaProp(l, #bytesSoFar)
      if bs <> gCurrentNetIds[i][2] then
        gCurrentNetIds[i][2] = bs
        gCurrentNetIds[i][4] = the milliSeconds
      else
        if (the milliSeconds - gCurrentNetIds[i][4]) > 25000 then
          file = gCurrentNetIds[i][3]
          add(gCurrentNetIds, [preloadNetThing(file), 0, file, the milliSeconds])
        end if
      end if
    end if
    if netDone(netId) then
      put "Done," && getaProp(l, #bytesSoFar)
      gBytes = gBytes + gCurrentNetIds[i][2]
      deleteAt(gCurrentNetIds, i)
      nextLoad()
    end if
  end repeat
  updateBar()
  go(the frame - 3)
end

on updateBar
  totalBytes = 856948
  b = 0
  repeat with i = 1 to count(gCurrentNetIds)
    b = b + gCurrentNetIds[i][2]
  end repeat
  f = 1.0 * (gBytes + b) / totalBytes
  if f > 1.0 then
    f = 1.0
  end if
  if f < gLastF then
    f = gLastF
  end if
  gLastF = f
  put "Loading Habbo Hotel... (" & integer(f * 100) & "%)" into field "status"
  progressSprite = sprite(3)
  spriteBox(progressSprite, progressSprite.left, progressSprite.top, progressSprite.left + (progressSprite.member.width * f), progressSprite.bottom)
end
