on prepareMovie
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
