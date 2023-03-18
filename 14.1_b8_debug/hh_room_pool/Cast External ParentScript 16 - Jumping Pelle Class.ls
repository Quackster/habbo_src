property direction, memberPrefix, memberModels, moving, destLScreen, startLScreen, moveStart, moveTime, talking, pModels, pDirections, pSprites, pInks, lParts, pActions, pColors, pLocZShifts, counter, pAnimFixH, pAnimFixV, pFlipped, mainAction, restingHeight, controller, userController, myEy, pLocFix, iLocZFix, swimSuitModels, swim, swimSdHeight, swimAnimCountDir, StayAndSwim, sign, signSpr, signDir, pModLevel, isModerator, name, pPelleImg, jumpAction, jumpAnimFrame, runAnimList, AnimListCounter, pSmallJumpList, changes, plastPressKey, pSpeed, pStatus, pnewLocV, pJumpSpeed, pVelocityV, pjumpBoardEnd, pjumpBoardStart, locX, locY, height, pMyLoc, pStartloc, pJumpDirection, pJumpLastDirection, pJumpMode, pJumpLoop, pJumpMaxAnimFrames, pJumpData, pPlayerMode, pLastJumpDirection, myLocZ, pScreenUpOrDown, pRemoveJumperTime, pBgScreenBuffer, pSpr, pXFactor, pYFactor, pPeopleSize, pMyName, pPelleBgImg, pJumpReady, pBigSplash, pBigSplashActive, pPelleKeys

on deconstruct me
  if ilk(pSpr, #sprite) then
    releaseSprite(pSpr.spriteNum)
  end if
  return 1
end

on Init me, tName, tMemberModels, tplayerMode, tKeyList
  pJumpReady = 0
  pBigSplashActive = 0
  pMyName = getObject(#session).get("user_name")
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  name = tName
  memberPrefix = "h"
  memberModels = tMemberModels
  counter = 0
  pModels = [:]
  pColors = [:]
  pInks = [:]
  pFlipped = [:]
  sort(pInks)
  sort(pColors)
  sort(pModels)
  lParts = []
  pSprites = [:]
  pLocFix = point(0, 0)
  iLocZFix = 0
  pPlayerMode = tplayerMode
  changes = 0
  pStatus = #Run
  lastPressKey = EMPTY
  pRemoveJumperTime = the milliSeconds
  pSpeed = 0
  jumpAction = "std"
  runAnimList = [0, 1, 2, 3, 3, 2, 1, 0]
  pSmallJumpList = [1, 1, 1, 2, 2, 2, 2, 2, 0, 0, 1]
  jumpAnimFrame = 0
  AnimListCounter = 1
  pJumpDirection = "u"
  pLastJumpDirection = "d"
  pJumpLastDirection = pJumpDirection
  pJumpLoop = 0
  pStartloc = point(545, 99)
  pSpr = sprite(reserveSprite(me.getID()))
  pSpr.loc = pStartloc
  locX = pSpr.locH
  locY = pSpr.locV
  pMyLoc = pSpr.loc
  pnewLocV = pSpr.locV
  pSpr.flipH = 1
  pSpr.flipV = 0
  myLocZ = 20000000
  pSpr.ink = 36
  pSpr.member = member(getmemnum("JumpingPelle"))
  pScreenUpOrDown = #up
  pVelocityV = 1.5
  pjumpBoardEnd = 393
  pjumpBoardStart = 523
  pJumpSpeed = 2
  pAnimFixV = [[0, 0, 1, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 0], [0, 1, 0, 1], [0, 1, 0, 1], [0, 0, 0, 1], [0, 0, 0, 0]]
  repeat with tParts in ["lh", "bd", "ch", "hd", "fc", "hr", "rh"]
    pModels[tParts] = tMemberModels[tParts]["model"]
    pColors[tParts] = tMemberModels[tParts]["color"]
  end repeat
  pPelleImg = image(60, 60, 32, rgb(155, 155, 255))
  pPelleBgImg = image(108, 102, 16, rgb(157, 206, 255))
  pBgScreenBuffer = image(member(getmemnum("pelle_bg3")).width, member(getmemnum("pelle_bg3")).height, 16, rgb(157, 206, 255))
  pBgScreenBuffer.fill(pBgScreenBuffer.rect, rgb(157, 206, 255))
  tPilvet = [point(141 + random(250), random(100)), point(141 + random(250), random(30) + 150), point(141 + random(250), random(20) + 240)]
  repeat with tPilvi in tPilvet
    tCloud = member(getmemnum("pilvi" & random(5)))
    tRect = tCloud.rect + rect(tPilvi.locH, tPilvi.locV, tPilvi.locH, tPilvi.locV)
    pBgScreenBuffer.copyPixels(tCloud.image, tRect, tCloud.rect, [#maskImage: tCloud.image.createMatte(), #ink: 8])
  end repeat
  pBgScreenBuffer.copyPixels(member(getmemnum("pelle_bg3")).image, pBgScreenBuffer.rect, pBgScreenBuffer.rect, [#maskImage: member(getmemnum("pelle_bg3")).image.createMatte(), #ink: 8])
  pKeyTimerStat = 0
  me.UpdatePelle()
  pPelleKeys = getVariableValue("swimjump.key.list")
  if pPelleKeys.ilk <> #propList then
    error(me, "Couldn't retrieve keymap for jump! Using default keys.", #jumpingPlaceOk)
    pPelleKeys = [#run1: "A", #run2: "D", #dive1: "W", #dive2: "E", #dive3: "A", #dive4: "S", #dive5: "D", #dive6: "Z", #dive7: "X", #jump: "SPACE"]
  end if
  return 1
end

on StopRunnig me
  if pStatus = #Run then
    pSpeed = pSpeed - 0.10000000000000001
    if pSpeed <= 0 then
      jumpAction = "std"
      jumpAnimFrame = 0
      pSpeed = 0
    end if
  end if
end

on StopJumping me
  if pMyLoc.locV > 511 then
    if pScreenUpOrDown = #up then
      pScreenUpOrDown = #down
      pMyLoc.locV = -20
      pnewLocV = pMyLoc.locV
      myLocZ = getIntVariable("window.default.locz", 0) - 10
      if name = pMyName then
        getThread(#pellehyppy).getComponent().poolDownView()
        tBalloonId = getThread(#room).getComponent().pBalloonId
        if objectExists(tBalloonId) then
          getObject(tBalloonId).showBalloons()
        end if
      end if
    end if
  else
    if pScreenUpOrDown = #down then
      pJumStoploc = point(429, 310)
      jumpReadyV = pJumStoploc.locV + ((pJumStoploc.locH - pMyLoc.locH) / 2)
      if (pBigSplashActive = 0) and (pMyLoc.locV >= (jumpReadyV - 40)) then
        pBigSplashActive = 1
        if not objectExists(#pool_bigSplash) then
          createObject(#pool_bigSplash, "AnimSprite Class", "BigSplash Class")
        end if
        tProps = [:]
        tProps[#visible] = 0
        tProps[#AnimFrames] = 20
        tProps[#startFrame] = 0
        tProps[#MemberName] = "big_splash_"
        tProps[#id] = "bigsplash"
        tProps[#loc] = pMyLoc - point(15, 15)
        getObject(#pool_bigSplash).setData(tProps)
        getObject(#pool_bigSplash).Activate()
        getObject(#pool_bigSplash).StartUpdateBigSplash()
      end if
      if pMyLoc.locV >= (jumpReadyV - 20) then
        myLocZ = getThread(#room).getInterface().getRoomVisualizer().getSprById("vesi2").locZ - 1
      end if
      if pMyLoc.locV >= jumpReadyV then
        pMyLoc.locV = jumpReadyV
        if pPlayerMode = 0 then
          pStatus = #ready
          if name = pMyName then
            repeat with f = 1 to length(pJumpData)
              temp = f
              if pJumpData.char[f] <> "0" then
                exit repeat
              end if
            end repeat
            pJumpData = "0" & pJumpData.char[temp..length(pJumpData)]
            sendJumpData = compressString(pJumpData)
            getThread(#pellehyppy).getComponent().sendJumpPerf(sendJumpData)
            pJumpData = EMPTY
          end if
        else
          pStatus = #dive
        end if
        if pScreenUpOrDown = #down then
          pJumpReady = 1
        end if
      end if
    end if
  end if
end

on UpdatePelle me
  pPelleImg.fill(pPelleImg.rect, rgb(255, 255, 255))
  repeat with f in ["bd", "lh", "hd", "fc", "hr", "ch", "rh"]
    case f of
      "ey":
        pInk = 36
      "ch":
        pInk = 41
      "sd":
        pInk = 32
      otherwise:
        pInk = 41
    end case
    tColor = pColors.getProp(f)
    if (f = "bd") or (f = "lh") or (f = "ch") or (f = "rh") then
      if jumpAction contains "jd" then
        dir = 0
      else
        dir = 2
      end if
      tMemNum = getmemnum("sh_" & jumpAction & "_" & f & "_" & pModels.getProp(f) & "_" & dir & "_" & jumpAnimFrame)
      if tMemNum < 0 then
        tMemNum = getmemnum("sh_" & "std" & "_" & f & "_" & pModels.getProp(f) & "_" & 2 & "_" & 0)
      end if
    else
      if (pJumpDirection = "d") or ((jumpAction contains "jus") and (jumpAnimFrame = 2)) then
        dir = 0
      else
        dir = 2
      end if
      tMemNum = getmemnum("sh_" & "std" & "_" & f & "_" & pModels.getProp(f) & "_" & dir & "_0")
    end if
    if tMemNum <> 0 then
      tImage = member(tMemNum).image
      tRegPoint = member(tMemNum).regPoint
      tX = -tRegPoint[1] + 10
      tY = pPelleImg.rect.height - tRegPoint[2] - 8
      tRect = rect(tX, tY, tX + tImage.width, tY + tImage.height)
      pPelleImg.copyPixels(tImage, tRect, tImage.rect, [#maskImage: tImage.createMatte(), #ink: pInk, #bgColor: tColor])
    end if
  end repeat
  tPelleMem = member(getmemnum("JumpingPelle"))
  tPelleMem.image.copyPixels(pPelleImg, pPelleImg.rect, pPelleImg.rect)
end

on JumpingExitFrame me
  if pStatus = #Run then
    if jumpAction = "run" then
      AnimListCounter = AnimListCounter + 1
      if AnimListCounter > runAnimList.count then
        AnimListCounter = 1
      end if
      jumpAnimFrame = runAnimList[AnimListCounter]
      pMyLoc.locH = pMyLoc.locH - (2 * integer(pSpeed))
      pnewLocV = pnewLocV + (1 * integer(pSpeed))
      if pSpeed > 1 then
        pMyLoc.locV = pnewLocV - jumpAnimFrame
      else
        pMyLoc.locV = pnewLocV
      end if
    end if
    me.UpdatePelle()
    if pMyLoc.locH <= (pjumpBoardEnd + 3) then
      jumpAnimFrame = 1
      pStatus = #jump
      pJumpSpeed = 1
    else
      pSpeed = pSpeed - 0.05
      if pSpeed < 0 then
        pSpeed = 0
      end if
    end if
    me.StopRunnig()
  else
    if pStatus = #jump then
      pMyLoc.locH = pMyLoc.locH - (2 * integer(pSpeed))
      pnewLocV = pnewLocV + (1 * integer(pSpeed)) - pJumpSpeed
      pMyLoc.locV = pnewLocV
      pJumpSpeed = pJumpSpeed - pVelocityV
      if pMyLoc.locH > pjumpBoardEnd then
        jumpBoardColV = pStartloc.locV + ((pStartloc.locH - pMyLoc.locH) / 2)
        if pMyLoc.locV >= jumpBoardColV then
          pMyLoc.locV = jumpBoardColV
          pStatus = #Run
          jumpAction = "std"
          jumpAnimFrame = 0
          StopRunnig(me)
          pJumpSpeed = 0
        end if
      else
        if pJumpSpeed < -12 then
          pJumpSpeed = -12
        end if
        pSpeed = pSpeed - 0.08
        if pSpeed < 0 then
          pSpeed = 0
        end if
      end if
      me.UpdatePelle()
      if pStatus = #jump then
        if (pMyLoc.locH > pjumpBoardEnd) and ((pMyLoc.locV - 3) > jumpBoardColV) then
          pJumpMode = #goinactive
        end if
        if (pJumpMode = #Active) and (pJumpLoop = 0) and (plastPressKey <> jumpAction.char[3]) then
          pJumpMode = #goinactive
        end if
        if (jumpAction = "jus") or (jumpAction = "jds") then
          pJumpMode = #Active
        end if
        if pJumpMode = #Active then
          jumpAnimFrame = jumpAnimFrame + 1
          if jumpAnimFrame > pJumpMaxAnimFrames then
            if pJumpLoop = 1 then
              jumpAnimFrame = 0
            else
              jumpAnimFrame = pJumpMaxAnimFrames
            end if
          end if
          if jumpAnimFrame = pJumpMaxAnimFrames then
            if (jumpAction = "jus") or (jumpAction = "jds") then
              jumpAnimFrame = 1
              pJumpMaxAnimFrames = 1
              if pJumpDirection = "u" then
                pJumpDirection = "d"
              else
                pJumpDirection = "u"
              end if
              jumpAction = "j" & pJumpDirection & "n"
            end if
          end if
        else
          if pJumpMode = #goinactive then
            if pJumpLoop = 1 then
              jumpAnimFrame = 0
              pJumpMode = #inactive
            else
              jumpAnimFrame = jumpAnimFrame - 1
              if jumpAnimFrame < 0 then
                jumpAnimFrame = 0
                pJumpMode = #inactive
              end if
            end if
            if (jumpAction = "jun") or (jumpAction = "jdn") then
              jumpAnimFrame = 1
            end if
          else
            if pJumpMode = #inactive then
              jumpAction = "jmp"
              if pJumpSpeed > 0 then
                jumpAnimFrame = 2
              else
                jumpAnimFrame = 0
              end if
              if pJumpSpeed < -5 then
                jumpAnimFrame = 1
                pJumpMaxAnimFrames = 1
                jumpAction = "j" & pJumpDirection & "n"
              end if
            end if
          end if
        end if
        if pMyLoc.locV > 511 then
          pStatus = #Run
          pSpeed = 0
          StopJumping(me)
        end if
        me.StopJumping()
      end if
    end if
  end if
  if pJumpLastDirection <> pJumpDirection then
    if pJumpDirection = "u" then
      pSpr.flipH = 1
      pSpr.flipV = 0
    else
      pSpr.flipH = 0
      pSpr.flipV = 1
    end if
  end if
  pJumpLastDirection = pJumpDirection
  pSpr.loc = pMyLoc
  pSpr.locZ = myLocZ
  if (name <> pMyName) and pPlayerMode and (pScreenUpOrDown = #up) then
    pSpr.loc = point(660, 72)
    pSpr.locZ = 33000
    if voidp(pPelleBgImg) then
      pSpr.locH = 1000
    end if
    pPelleBgImg.fill(rect(0, 0, 108, 102), rgb(157, 206, 255))
    h = pPelleImg.height - 4
    w = pPelleImg.width - 6
    BgsourceRect = pPelleBgImg.rect + rect(pMyLoc.locH - w, pMyLoc.locV - h, pMyLoc.locH - w, pMyLoc.locV - h)
    pBgScreenBuffer.copyPixels(member(getmemnum("pomppulauta_4")).image, rect(393, 131, 523, 199), member(getmemnum("pomppulauta_4")).rect, [#maskImage: member(getmemnum("pomppulauta_4")).image.createMatte(), #ink: 8])
    pPelleBgImg.copyPixels(pBgScreenBuffer, rect(0, 0, 108, 102), BgsourceRect)
  end if
end

on jumpBoardCollisionD me, tNum
  return pStartloc.locV + integer((pStartloc.locH - tNum) / 2)
end

on translateKey me, tPelleKey
  if tPelleKey = SPACE then
    return SPACE
  end if
  tKeyList = ["a", "d", "w", "e", "a", "s", "d", "z", "x"]
  repeat with i = 1 to pPelleKeys.count
    if tPelleKey = pPelleKeys[i] then
      return tKeyList[i]
    end if
  end repeat
  return "0"
end

on MykeyDown me, tPelleKey, tTimeElapsed, tNoTranslation
  if not tNoTranslation then
    tPelleKey = me.translateKey(tPelleKey)
  end if
  if pStatus = #Run then
    case tPelleKey of
      "a", "d":
        if tPelleKey <> plastPressKey then
          tRunOK = 1
        end if
        if tRunOK then
          jumpAction = "run"
          pSpeed = pSpeed + 0.59999999999999998
          if pSpeed > 4 then
            pSpeed = 4
          end if
          pJumpData = pJumpData & tPelleKey
        else
          pJumpData = pJumpData & "0"
        end if
      SPACE:
        if pStatus <> #jump then
          ppJumpMode = #inactive
          pJumpLoop = 1
          jumpAction = "jmp"
          jumpAnimFrame = 1
          pStatus = #jump
          pJumpSpeed = 0
          if (pMyLoc.locH < pjumpBoardStart) and (pMyLoc.locH > pjumpBoardEnd) then
            pJumpSpeed = (pjumpBoardStart - pMyLoc.locH) / 22 * pSpeed
          end if
          pJumpSpeed = pJumpSpeed + 5
          pJumpDirection = "u"
        end if
        if pSpeed < 1 then
          pSpeed = pSpeed + 0.5
        end if
        pJumpData = pJumpData & tPelleKey
      otherwise:
        pSpeed = pSpeed - 0.20000000000000001
        if pSpeed < 0 then
          pSpeed = 0
        end if
        pJumpData = pJumpData & "0"
    end case
  else
    if pStatus = #jump then
      hyppyKesken = 0
      if (pJumpLoop = 0) and (tPelleKey <> jumpAction.char[3]) then
        if (jumpAction <> "jun") and (jumpAction <> "jdn") then
          hyppyKesken = 1
        end if
      end if
      if hyppyKesken = 0 then
        case tPelleKey of
          "w":
            if jumpAction <> ("j" & pJumpDirection & "w") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "w"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            pJumpMaxAnimFrames = 1
          "a":
            if jumpAction <> ("j" & pJumpDirection & "a") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "a"
            pJumpLoop = 1
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            if pJumpDirection = "u" then
              pJumpMaxAnimFrames = 4
            else
              pJumpMaxAnimFrames = 7
            end if
          "d":
            if jumpAction <> ("j" & pJumpDirection & "d") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "d"
            pJumpLoop = 1
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            if pJumpDirection = "u" then
              pJumpMaxAnimFrames = 6
            else
              pJumpMaxAnimFrames = 5
            end if
          "e":
            if jumpAction <> ("j" & pJumpDirection & "e") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "e"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            pJumpMaxAnimFrames = 1
          "z":
            if jumpAction <> ("j" & pJumpDirection & "z") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "z"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            pJumpMaxAnimFrames = 1
          "x":
            if jumpAction <> ("j" & pJumpDirection & "x") then
              jumpAnimFrame = 0
            end if
            jumpAction = "j" & pJumpDirection & "x"
            pJumpLoop = 0
            pJumpMode = #Active
            pJumpData = pJumpData & tPelleKey
            pJumpMaxAnimFrames = 1
          "s":
            if pMyLoc.locH > pjumpBoardEnd then
              pJumpDirection = "u"
            else
              if jumpAction <> ("j" & pJumpDirection & "s") then
                jumpAnimFrame = 0
              end if
              jumpAction = "j" & pJumpDirection & "s"
              pJumpLoop = 0
              pJumpMode = #Active
              pJumpMaxAnimFrames = 3
            end if
            pJumpData = pJumpData & tPelleKey
          otherwise:
            pJumpData = pJumpData & "0"
        end case
      else
        pJumpData = pJumpData & tPelleKey
      end if
    end if
  end if
  plastPressKey = tPelleKey
  me.JumpingExitFrame()
end

on NotKeyDown me
  if the milliSeconds > (pRemoveJumperTime + 45000) then
    if pMyLoc.locH > pjumpBoardEnd then
      pStatus = #Run
      jumpAction = "run"
      pSpeed = 2
    end if
    if not voidp(pJumpData) then
      if pJumpData.char[length(pJumpData)] = "a" then
        presskey = "d"
      else
        presskey = "a"
      end if
      me.MykeyDown(presskey, VOID, 1)
    else
      pJumpData = pJumpData & "a"
    end if
  else
    pJumpData = pJumpData & "0"
    pJumpMode = #inactive
    me.JumpingExitFrame()
  end if
end
