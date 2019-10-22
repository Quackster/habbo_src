property pReplayAnimWnd, pJumpData, pName, pPlayBackAnimR, pKeyAcceptTime, pKeycounter, pJumpDone

on construct me 
  pReplayAnimWnd = "playBackR"
  pPlayBackAnimR = 1
  return TRUE
end

on deconstruct me 
  if windowExists(pReplayAnimWnd) then
    removeWindow(pReplayAnimWnd)
  end if
  if (ilk(me.pSpr) = #sprite) then
    releaseSprite(me.pSpr.spriteNum)
  end if
  removeUpdate(me.getID())
  return TRUE
end

on initPlayer me, jname, jdata 
  pJumpDone = 0
  pName = jname
  pJumpData = decompressString(jdata)
  pJumpData = "0000" & pJumpData & "0000000000"
  plastPressKey = void()
  me.openHidePlayBackWindow()
  receiveUpdate(me.getID())
  return TRUE
end

on openHidePlayBackWindow me 
  if pName <> getObject(#session).GET("user_name") then
    return FALSE
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
  if (tWndObj = 0) then
    return FALSE
  end if
  tAnim = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1, 0]
  tImg = member(getmemnum("R_" & tAnim.getAt(pPlayBackAnimR))).image.duplicate()
  tWndObj.getElement("ph_playback_r_img").feedImage(tImg)
  pPlayBackAnimR = (pPlayBackAnimR + 1)
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
    pKeyAcceptTime = (the milliSeconds - 101)
  end if
  if the milliSeconds >= pKeyAcceptTime then
    pKeycounter = (pKeycounter + 1)
    if pKeycounter <= pJumpData.length then
      if pJumpData.getProp(#char, pKeycounter) <> "0" then
        me.MykeyDown(pJumpData.getProp(#char, pKeycounter), (the milliSeconds - pKeyAcceptTime), 1)
      else
        me.NotKeyDown((the milliSeconds - pKeyAcceptTime), 1)
      end if
      pKeyAcceptTime = (the milliSeconds + (100 - (the milliSeconds - pKeyAcceptTime)))
    else
      if (pJumpDone = 0) and (pName = getObject(#session).GET("user_name")) then
        pJumpDone = 1
        tSplashPos = getThread(#room).getInterface().getGeometry().getWorldCoordinate(me.pMyLoc.locH, me.pMyLoc.locV)
        if (tSplashPos = 0) then
          getThread(#room).getComponent().getRoomConnection().send("SPLASH_POSITION", [#integer:21, #integer:19])
        else
          tMessage = [:]
          tMessage.addProp(#integer, integer(tSplashPos.getAt(1)))
          tMessage.addProp(#integer, integer(tSplashPos.getAt(2)))
          getThread(#room).getComponent().getRoomConnection().send("SPLASH_POSITION", tMessage)
        end if
      end if
      me.openHidePlayBackWindow()
      getThread(#pellehyppy).getInterface().activateChatField()
      removeObject(me.getID())
    end if
  end if
end
