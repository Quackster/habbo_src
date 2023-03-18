on exitFrame
  global goJumper, gKeyAcceptTime, gMyName, gUserSprites, gPopUpContext
  if objectp(gPopUpContext) then
    close(gPopUpContext)
  end if
  spr = getObjectSprite(gMyName)
  o = getaProp(gUserSprites, spr)
  gKeyAcceptTime = VOID
  goJumper = VOID
  set the scriptInstanceList of sprite 40 to []
  goJumper = new(script("JumpingPelle Class"), gMyName, o.memberModels, o.pPelleswimSuitModels, 0)
  set the scriptInstanceList of sprite 40 to [goJumper]
  sendFuseMsg("JUMPSTART")
  AddtoStatistic = "Kultakala_Uimahyppy"
  preloadNetThing("http://stat.www.fi/cgi-bin/stat2?serv=kolumbus.fi&page=" & AddtoStatistic)
end
