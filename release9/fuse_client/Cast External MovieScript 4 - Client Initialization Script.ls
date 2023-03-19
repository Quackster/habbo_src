on startClient
  if not constructObjectManager() then
    return 0
  end if
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
    startClient()
  else
    tURL = getMoviePath()
    if objectExists(#session) then
      if getObject(#session).exists("client_url") then
        tURL = deobfuscate(getObject(#session).get("client_url"))
      end if
    end if
    gotoNetPage(tURL)
  end if
  return 1
end
