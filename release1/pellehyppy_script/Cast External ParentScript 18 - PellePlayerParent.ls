property pKeyAcceptTime, pKeycounter, pJumpData, pName
global goJumper, gPellePlayer, gMyName, gUserSprites, gpShowSprites, gpelleBgImg

on new me, jname, jdata
  pName = jname
  pJumpData = decompressString(jdata)
  pJumpData = "0000" & pJumpData & "0000000000"
  spr = getObjectSprite(jname)
  o = getaProp(gUserSprites, spr)
  member("JumpData").text = decompressString(member("JumpData").text)
  goJumper = VOID
  set the scriptInstanceList of sprite 40 to []
  goJumper = new(script("JumpingPelle Class"), jname, o.memberModels, o.pPelleswimSuitModels, 1)
  set the scriptInstanceList of sprite 40 to [goJumper]
  return me
end

on PlayerLoop me
  if pKeyAcceptTime = VOID then
    if pKeycounter = VOID then
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
      if pJumpData.char[pKeycounter] <> "0" then
        goJumper.MykeyDown(pJumpData.char[pKeycounter], the milliSeconds - pKeyAcceptTime)
      else
        goJumper.NotKeyDown(the milliSeconds - pKeyAcceptTime)
      end if
      pKeyAcceptTime = the milliSeconds + (100 - (the milliSeconds - pKeyAcceptTime))
    else
      if pName = gMyName then
        splashPos = getWorldCoordinate(goJumper.pMyLoc.locH, goJumper.pMyLoc.locV)
        if voidp(splashPos) then
          put "tippui kartan ulkopuolell"
          sendFuseMsg("SPLASH_POSITION" && "21,19")
        else
          sendFuseMsg("SPLASH_POSITION" && splashPos[1] & "," & splashPos[2])
        end if
      end if
      set the scriptInstanceList of sprite 40 to []
      sprite(40).locH = 1000
      goJumper = VOID
      gPellePlayer = VOID
      gpelleBgImg = VOID
      if the frameLabel <> "pool_b" then
        go("pool_b")
      end if
    end if
  end if
end
