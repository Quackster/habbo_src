on prepareMovie
  if not (the runMode contains "Author") then
    tEnv = the environment
    tParams = "{"
    tParams = tParams & "version:'" & tEnv[#productVersion] & "'"
    tParams = tParams & ",build:'" & tEnv[#productBuildVersion] & "'"
    tParams = tParams & ",os:'" & tEnv[#osVersion] & "'"
    tParams = tParams & "}"
    script("initProxyJS").initCall(tParams)
  end if
  the debugPlaybackEnabled = 0
  castLib(2).preloadMode = 1
  preloadNetThing(castLib(2).fileName)
  moveToFront(the stage)
  set the exitLock to 1
  puppetTempo(15)
end

on stopMovie
  stopClient()
  go(1)
end
