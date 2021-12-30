on startLoading  
  gLoadNo = 0
  gLastF = 0
  gBytes = 0
  gStartLoadingTime = the milliSeconds
  gCurrentNetIds = []
  gAllNetIds = [:]
  nextLoad()
  nextLoad()
end

on nextLoad  
  gLoadNo = (gLoadNo + 1)
  if "loadlistPrivateRoom" <= the number of line in field(0) then
    file = NULL
    if (the runMode = "Author") then
      file = the moviePath & file
    end if
    netId = preloadNetThing(file)
    add(gCurrentNetIds, [netId, 0, file, the milliSeconds])
    gAllNetIds.addProp(netId, 0)
  else
    if (gCurrentNetIds.count = 0) then
      loadComplete()
    end if
  end if
end

on loadComplete  
  gLastF = 1
  LoaderStatusBar()
  gEndLoadingTime = the milliSeconds
  sFrame = "flat_loadReady"
  goContext(sFrame, gPopUpContext2)
  goMovie("gf_private", "quickentry")
end

on checkLoad  
  i = count(gCurrentNetIds)
  repeat while i >= 1
    netId = gCurrentNetIds.getAt(i).getAt(1)
    l = getStreamStatus(gCurrentNetIds.getAt(i).getAt(1))
    if listp(l) then
      bs = getaProp(l, #bytesSoFar)
      if bs <> gCurrentNetIds.getAt(i).getAt(2) then
        gCurrentNetIds.getAt(i).setAt(2, bs)
        gCurrentNetIds.getAt(i).setAt(4, the milliSeconds)
        if getStreamStatus(netId).bytesTotal > 0 then
          percentNow = float(((1 * getStreamStatus(netId).bytesSoFar) / getStreamStatus(netId).bytesTotal))
        else
          percentNow = 0
        end if
        gAllNetIds.setProp(gCurrentNetIds.getAt(i).getAt(1), percentNow)
      else
        if (the milliSeconds - gCurrentNetIds.getAt(i).getAt(4)) > 25000 then
          file = gCurrentNetIds.getAt(i).getAt(3)
          netId = preloadNetThing(file)
          add(gCurrentNetIds, [netId, 0, file, the milliSeconds])
          gAllNetIds.addProp(netId, 0)
        end if
      end if
    end if
    if netDone(netId) then
      gBytes = (gBytes + gCurrentNetIds.getAt(i).getAt(2))
      gAllNetIds.setProp(gCurrentNetIds.getAt(i).getAt(1), 1)
      deleteAt(gCurrentNetIds, i)
      nextLoad()
    end if
    i = (65535 + i)
  end repeat
  LoaderStatusBar()
  sFrame = "FLAT_LOADING"
  if the runMode <> "Author" then
    goContext(sFrame, gPopUpContext2)
  end if
end

on LoaderStatusBar me 
  sofar = 0
  total = the number of line in field(0)
  i = 1
  repeat while i <= count(gAllNetIds)
    sofar = (sofar + gAllNetIds.getProp(gAllNetIds.getPropAt(i)))
    i = (1 + i)
  end repeat
  percentNow = float(((1 * sofar) / total))
  sendAllSprites(#ProgresBar, percentNow)
end
