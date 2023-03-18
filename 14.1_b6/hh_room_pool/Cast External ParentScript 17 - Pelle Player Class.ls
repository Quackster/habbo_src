property pKeyAcceptTime, pKeycounter, pJumpData, pName, pJumpDone, pReplayAnimWnd, pPlayBackAnimR

on construct me
  pReplayAnimWnd = "playBackR"
  pPlayBackAnimR = 1
  return 1
end

on deconstruct me
  if windowExists(pReplayAnimWnd) then
    removeWindow(pReplayAnimWnd)
  end if
  if ilk(me.pSpr) = #sprite then
    releaseSprite(me.pSpr.spriteNum)
  end if
  removeUpdate(me.getID())
  return 1
end

on initPlayer me, jname, jdata
  pJumpDone = 0
  pName = jname
  pJumpData = decompressString(jdata)
  pJumpData = "0000" & pJumpData & "0000000000"
  plastPressKey = VOID
  me.openHidePlayBackWindow()
  receiveUpdate(me.getID())
  return 1
end

on openHidePlayBackWindow me
  if pName <> getObject(#session).get("user_name") then
    return 0
  end if
  if windowExists(pReplayAnimWnd) then
    removeWindow(pReplayAnimWnd)
  else
    createWindow(pReplayAnimWnd, "ph_playback.window", 15, 10)
    getWindow(pReplayAnimWnd).resizeTo(56, 64)
    getWindow(pReplayAnimWnd).moveZ(19000020)
    getWindow(pReplayAnimWnd).lock()
    pPlayBackAnimR = 1
  end if
end

on animatePlayBackR me
  tWndObj = getWindow(pReplayAnimWnd)
  if tWndObj = 0 then
    return 0
  end if
  tAnim = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1, 0]
  tImg = member(getmemnum("R_" & tAnim[pPlayBackAnimR])).image.duplicate()
  tWndObj.getElement("ph_playback_r_img").feedImage(tImg)
  pPlayBackAnimR = pPlayBackAnimR + 1
  if pPlayBackAnimR > tAnim.count then
    pPlayBackAnimR = 1
  end if
end

on update me
  me.animatePlayBackR()
  if voidp(pKeyAcceptTime) then
    if voidp(pKeycounter) then
      pKeycounter = 0
    end if
    pKeyAcceptTime = the milliSeconds - 101
  end if
  if the milliSeconds >= pKeyAcceptTime then
    pKeycounter = pKeycounter + 1
    if pKeycounter <= pJumpData.length then
      if pJumpData.char[pKeycounter] <> "0" then
        me.MykeyDown(pJumpData.char[pKeycounter], the milliSeconds - pKeyAcceptTime, 1)
      else
        me.NotKeyDown(the milliSeconds - pKeyAcceptTime, 1)
      end if
      pKeyAcceptTime = the milliSeconds + (100 - (the milliSeconds - pKeyAcceptTime))
    else
      if (pJumpDone = 0) and (pName = getObject(#session).get("user_name")) then
        pJumpDone = 1
        tSplashPos = getThread(#room).getInterface().getGeometry().getWorldCoordinate(me.pMyLoc.locH, me.pMyLoc.locV)
        if tSplashPos = 0 then
          getThread(#room).getComponent().getRoomConnection().send("SPLASH_POSITION", "21,19")
        else
          getThread(#room).getComponent().getRoomConnection().send("SPLASH_POSITION", tSplashPos[1] & "," & tSplashPos[2])
        end if
      end if
      me.openHidePlayBackWindow()
      getThread(#pellehyppy).getInterface().activateChatField()
      removeObject(me.getID())
    end if
  end if
end
