on prepareMovie
  tellStreamStatus(1)
  preload(the lastFrame)
  repeat with f = 1 to the number of castLibs
    castLib(f).preloadMode = 2
    if castLib(f).name <> "Internal" then
      preloadNetThing(the moviePath & castLib(f).name & ".cct")
    end if
  end repeat
end

on streamStatus url, state, bytesSoFar, bytesTotal
  if the frame = 1 then
    AreWeFinished = 1
    repeat with f = 1 to the number of castLibs
      if member(the number of castMembers of castLib f, f).mediaReady = 1 then
      else
        put "STILL LOADING" && member(the number of castMembers of castLib f, f).name, "of cast", f
        AreWeFinished = 0
      end if
      if (url = (the moviePath & castLib(f).name & ".cct")) and (state = "InProgress") then
        put "STILL LOADING CAST" && url & RETURN & the moviePath & castLib(f).name & ".cct"
        AreWeFinished = 0
      end if
    end repeat
    if AreWeFinished = 0 then
      put "EI VIEL€ LATAUTUNUT"
    else
      put "NYT VALMIS"
      tellStreamStatus(0)
      go(the frame + 1)
    end if
  else
    tellStreamStatus(0)
  end if
end
