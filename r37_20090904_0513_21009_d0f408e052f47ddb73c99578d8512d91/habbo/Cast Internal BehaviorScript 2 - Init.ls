on exitFrame me
  if netDone() then
    if the traceScript then
      return 0
    end if
    the traceScript = 0
    the traceLogFile = EMPTY
    _movie.traceScript = 0
    _player.traceScript = 0
    if 1 then
      initializeAndRun()
    end if
  else
    go(the frame)
  end if
end

on handler
  return []
end

on handlers
  return []
end
