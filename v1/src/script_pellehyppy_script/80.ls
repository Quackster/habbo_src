property pJumpData, pKeyAcceptTime, pKeycounter, pName

on new me, jname, jdata 
  pName = jname
  pJumpData = decompressString(jdata)
  pJumpData = "0000" & pJumpData & "0000000000"
  spr = getObjectSprite(jname)
  o = getaProp(gUserSprites, spr)
  member("JumpData").text = decompressString(member("JumpData").text)
  goJumper = void()
  sprite(40).undefined = []
  goJumper = new(script("JumpingPelle Class"), jname, o.memberModels, o.pPelleswimSuitModels, 1)
  sprite(40).undefined = [goJumper]
  return(me)
end

on PlayerLoop me 
  if pKeyAcceptTime = void() then
    if pKeycounter = void() then
      pKeycounter = 0
    end if
    pKeyAcceptTime = the milliSeconds - 101
    spr = getaProp(gpShowSprites, "cam1")
    if spr > 0 then
      sendSprite(spr, symbol("fuseShow_" & "showtext"), pName)
    end if
  end if
  if the milliSeconds >= pKeyAcceptTime then
    pKeycounter = pKeycounter + 1
    if pKeycounter <= pJumpData.length then
      if pJumpData.getProp(#char, pKeycounter) <> "0" then
        goJumper.MykeyDown(pJumpData.getProp(#char, pKeycounter), the milliSeconds - pKeyAcceptTime)
      else
        goJumper.NotKeyDown(the milliSeconds - pKeyAcceptTime)
      end if
      pKeyAcceptTime = the milliSeconds + 100 - the milliSeconds - pKeyAcceptTime
    else
      if pName = gMyName then
        splashPos = getWorldCoordinate(goJumper.pMyLoc.locH, goJumper.pMyLoc.locV)
        if voidp(splashPos) then
          put("tippui kartan ulkopuolell")
          sendFuseMsg("SPLASH_POSITION" && "21,19")
        else
          sendFuseMsg("SPLASH_POSITION" && splashPos.getAt(1) & "," & splashPos.getAt(2))
        end if
      end if
      sprite(40).undefined = []
      sprite(40).locH = 1000
      goJumper = void()
      gPellePlayer = void()
      gpelleBgImg = void()
      if the frameLabel <> "pool_b" then
        go("pool_b")
      end if
    end if
  end if
end
