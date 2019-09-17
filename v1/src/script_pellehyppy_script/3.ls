on exitFrame  
  if objectp(gPopUpContext) then
    close(gPopUpContext)
  end if
  spr = getObjectSprite(gMyName)
  o = getaProp(gUserSprites, spr)
  gKeyAcceptTime = void()
  goJumper = void()
  sprite(40).undefined = []
  goJumper = new(script("JumpingPelle Class"), gMyName, o.memberModels, o.pPelleswimSuitModels, 0)
  sprite(40).undefined = [goJumper]
  sendFuseMsg("JUMPSTART")
  AddtoStatistic = "Kultakala_Uimahyppy"
  preloadNetThing("http://stat.www.fi/cgi-bin/stat2?serv=kolumbus.fi&page=" & AddtoStatistic)
end
