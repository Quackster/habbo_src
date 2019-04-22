property pTimeStamps, pTimeoutName, pTimeoutsPerSec, pMeasuringStart

on new me 
  pTimeStamps = []
  pTimeoutName = "response meter"
  pTimeoutsPerSec = 48
  pMeasuringStart = the milliSeconds
  return(me)
end

on handleTimeout me 
  pTimeStamps.add(the milliSeconds)
end

on startMeasuring me 
  pTimeStamps = []
  pMeasuringStart = the milliSeconds
  -- UNK_B3 719
  t = ERROR
end

on stopMeasuring me 
  timeout(pTimeoutName).forget()
end

on printGraph me 
  tTotalTime = pTimeStamps.getAt(pTimeStamps.count) - pMeasuringStart
  tExpectedCount = tTotalTime / 1000 / pTimeoutsPerSec - 1
  put("Timeout per second :" & pTimeoutsPerSec)
  put("Total Time : " & tTotalTime & " ms")
  put("Expected count : " & tExpectedCount)
  put("Recorded count : " & pTimeStamps.count)
  i = 1
  repeat while i <= pTimeStamps.count
    tTime = pTimeStamps.getAt(i)
    tExpected = pMeasuringStart + i - 1 * 1000 / pTimeoutsPerSec
    tLate = tTime - tExpected
    if i > 1 then
      tLastTime = pTimeStamps.getAt(i - 1)
    else
      tLastTime = pMeasuringStart
    end if
    put("Late : " & tLate & " ms, skipped : " & integer(tTime - tLastTime / 1000 / pTimeoutsPerSec) - 1)
    i = 1 + i
  end repeat
end

on getSkipCountAsString me 
  tOut = ""
  tTotalTime = pTimeStamps.getAt(pTimeStamps.count) - pMeasuringStart
  tExpectedCount = tTotalTime / 1000 / pTimeoutsPerSec - 1
  i = 1
  repeat while i <= pTimeStamps.count
    tTime = pTimeStamps.getAt(i)
    tExpected = pMeasuringStart + i - 1 * 1000 / pTimeoutsPerSec
    tLate = tTime - tExpected
    if i > 1 then
      tLastTime = pTimeStamps.getAt(i - 1)
    else
      tLastTime = pMeasuringStart
    end if
    tOut = tOut & integer(tTime - tLastTime / 1000 / pTimeoutsPerSec) - 1
    tOut = tOut & "\t"
    i = 1 + i
  end repeat
  return(tOut)
end
