on initializeAndRun
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
  if (new script(member(5, 1))).getV("lkjsdlfjg23r098rsadfjj3490f3qf90jfasjdfoasidjoijjj") <> "dfsjbniou3n403q9fksadkjfash439h8f98hsadf98h938hfaskjhf34" then
    return 0
  end if
  if not constructObjectManager() then
    return 0
  end if
  if not constructProfileManager() then
    return 0
  end if
  startProfilingTask("Client Initialization::initCore")
  if not dumpVariableField("System Props") then
    return stopClient()
  end if
  if not resetCastLibs(0, 0) then
    return stopClient()
  end if
  if not getResourceManager().preIndexMembers() then
    return stopClient()
  end if
  if not dumpTextField("System Texts") then
    return stopClient()
  end if
  if not getThreadManager().create(#core, #core) then
    return stopClient()
  end if
  finishProfilingTask("Client Initialization::initCore")
  return 1
end

on stopClient
  global gCore
  if the runMode contains "Author" then
    if voidp(gCore) then
      return 0
    end if
    if the runMode contains "Author" then
      deconstructConnectionManager()
      deconstructObjectManager()
      deconstructErrorManager()
    end if
  end if
  return 0
end

on resetClient
  if the runMode contains "Author" then
    stopClient()
  else
    tURL = getMoviePath()
    if objectExists(#session) then
      if getObject(#session).exists("client_url") then
        tURL = deobfuscate(getObject(#session).GET("client_url"))
      end if
    end if
    gotoNetPage(tURL)
  end if
  return 1
end

on handlers
  return []
end
