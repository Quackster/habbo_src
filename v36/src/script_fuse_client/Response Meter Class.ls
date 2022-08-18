property pTimeStamps, pTimeoutName, pTimeoutsPerSec, pMeasuringStart

on new me
  pTimeStamps = []
  pTimeoutName = "response meter"
  pTimeoutsPerSec = 48
  pMeasuringStart = the milliSeconds
  return me
end

on handleTimeout me
  pTimeStamps.add(the milliSeconds)
end

on startMeasuring me
  pTimeStamps = []
  pMeasuringStart = the milliSeconds
  t = new timeout(pTimeoutName, (1000 / pTimeoutsPerSec), #handleTimeout, me)
end

on stopMeasuring me
  timeout(pTimeoutName).forget()
end

on printGraph me
  tTotalTime = (pTimeStamps[pTimeStamps.count] - pMeasuringStart)
  tExpectedCount = ((tTotalTime / (1000 / pTimeoutsPerSec)) - 1)
  put ("Timeout per second :" & pTimeoutsPerSec)
  put (("Total Time : " & tTotalTime) & " ms")
  put ("Expected count : " & tExpectedCount)
  put ("Recorded count : " & pTimeStamps.count)
  repeat with i = 1 to pTimeStamps.count
    tTime = pTimeStamps[i]
    tExpected = (pMeasuringStart + ((i - 1) * (1000 / pTimeoutsPerSec)))
    tLate = (tTime - tExpected)
    if (i > 1) then
      tLastTime = pTimeStamps[(i - 1)]
    else
      tLastTime = pMeasuringStart
    end if
    put ((("Late : " & tLate) & " ms, skipped : ") & (integer(((tTime - tLastTime) / (1000 / pTimeoutsPerSec))) - 1))
  end repeat
end

on getSkipCountAsString me
  tOut = EMPTY
  tTotalTime = (pTimeStamps[pTimeStamps.count] - pMeasuringStart)
  tExpectedCount = ((tTotalTime / (1000 / pTimeoutsPerSec)) - 1)
  repeat with i = 1 to pTimeStamps.count
    tTime = pTimeStamps[i]
    tExpected = (pMeasuringStart + ((i - 1) * (1000 / pTimeoutsPerSec)))
    tLate = (tTime - tExpected)
    if (i > 1) then
      tLastTime = pTimeStamps[(i - 1)]
    else
      tLastTime = pMeasuringStart
    end if
    tOut = (tOut & (integer(((tTime - tLastTime) / (1000 / pTimeoutsPerSec))) - 1))
    tOut = (tOut & TAB)
  end repeat
  return tOut
end
