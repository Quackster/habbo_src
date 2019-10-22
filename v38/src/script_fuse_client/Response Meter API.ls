on startResponseMeter  
  if not objectp(g_meterObj) then
    g_meterObj = ["Response Meter Class"]
  end if
  g_meterObj.startMeasuring()
end

on stopResponseMeter  
  if not objectp(g_meterObj) then
    put("Error : Response meter not started yet!")
    return FALSE
  end if
  g_meterObj.stopMeasuring()
end

on printResponseMeterGraph  
  if not objectp(g_meterObj) then
    put("Error : Response meter not started yet!")
    return FALSE
  end if
  g_meterObj.printGraph()
end

on clearResponseMeter  
  g_meterObj = void()
end

on printSkipCountToFile tFileName 
  if voidp(g_io) then
    -- UNK_B3 1408
    g_io = ERROR
  end if
  g_io.openfile(the moviePath & tFileName, 0)
  g_io.delete()
  g_io.closeFile()
  g_io.createFile(the moviePath & tFileName)
  tString = g_meterObj.getSkipCountAsString()
  g_io.openfile(the moviePath & tFileName, 2)
  g_io.writeString(tString)
  g_io.closeFile()
end
