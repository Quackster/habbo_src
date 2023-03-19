global _player

on prepareMovie
  if the traceScript then
    return 0
  end if
  the traceScript = 0
  the traceLogFile = EMPTY
  _movie.traceScript = 0
  _player.traceScript = 0
  if _player.windowList.count > 0 then
    return stopMovie()
  end if
  if not (the runMode contains "Author") then
    tProcessLogURL = EMPTY
    tAccountID = EMPTY
    tDelim = the itemDelimiter
    repeat with i = 1 to 9
      tParamBundle = externalParamValue("sw" & i)
      if not voidp(tParamBundle) then
        the itemDelimiter = ";"
        repeat with j = 1 to tParamBundle.item.count
          tParam = tParamBundle.item[j]
          the itemDelimiter = "="
          if tParam.item.count > 1 then
            tKey = tParam.item[1]
            tValue = tParam.item[2..tParam.item.count]
            if tKey = "processlog.url" then
              tProcessLogURL = tValue
            else
              if tKey = "account_id" then
                tAccountID = tValue
              end if
            end if
          end if
          the itemDelimiter = ";"
        end repeat
      end if
    end repeat
    the itemDelimiter = tDelim
    if tProcessLogURL <> EMPTY then
      postNetText(tProcessLogURL, ["step": 8, "account_id": tAccountID])
    end if
  end if
  if (the activeWindow).name <> "stage" then
    return stopMovie()
  end if
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
