property pSprite, pOffset, pProps, pDirection, pmodel, pDelayCounter

on define me, tSprite, ttype
  pSprite = [tSprite]
  if ttype > 1 then
    tVisualID = getThread(#entry).getInterface().pEntryVisual
    tVisualizer = getVisualizer(tVisualID)
    pSprite[2] = tVisualizer.getSprById("boat" & ttype & "_roof")
  end if
  pOffset = [0, 0]
  pmodel = "boat_" & ttype
  pDelayCounter = 1
  case pmodel of
    "boat_1":
      pProps = [#left: point(723, 335), #right: point(371, 511), #leftlimit: 370, #rightlimit: 720]
    "boat_2":
      pProps = [#left: point(375, 284), #right: point(215, 500), #leftlimit: 500, #rightlimit: 275, #turn: 510]
    "boat_3":
      pProps = [#left: point(314, 230), #right: point(250, 520), #leftlimit: 500, #rightlimit: 230, #turn: 570]
  end case
  me.reset()
  return 1
end

on reset me
  if pDelayCounter <= 0 then
    pDelayCounter = random(8) * 10
  end if
  pDirection = [#left, #right][random(2)]
  if pmodel = "boat_1" then
    if pDirection = #left then
      pSprite[1].loc = pProps[#left]
      pOffset = [-2, 1]
    else
      pSprite[1].loc = pProps[#right]
      pOffset = [2, -1]
    end if
  else
    if pDirection = #left then
      repeat with tSpr in pSprite
        tSpr.flipH = 1
        tSpr.loc = pProps[#left]
      end repeat
      pOffset = [2, 1]
    else
      repeat with tSpr in pSprite
        tSpr.flipH = 0
        tSpr.loc = pProps[#right]
      end repeat
      pOffset = [2, -1]
    end if
    pSprite[2].ink = 41
    pSprite[2].backColor = random(150) + 20
  end if
end

on update me
  if pDelayCounter > 0 then
    pDelayCounter = pDelayCounter - 1
    return 1
  end if
  if pmodel = "boat_1" then
    pSprite[1].loc = pSprite[1].loc + pOffset
    if ((pDirection = #left) and (pSprite[1].locH < pProps[#leftlimit])) or ((pDirection = #right) and (pSprite[1].locH > pProps[#rightlimit])) then
      return me.reset()
    end if
  else
    repeat with tSpr in pSprite
      tSpr.loc = tSpr.loc + pOffset
    end repeat
    if ((pDirection = #left) and (pSprite[1].locV > pProps[#leftlimit])) or ((pDirection = #right) and (pSprite[1].locV < pProps[#rightlimit])) then
      return me.reset()
    end if
    if pSprite[1].locH > pProps[#turn] then
      if pDirection = #left then
        pOffset = [-2, 1]
        repeat with tSpr in pSprite
          tSpr.flipH = 0
        end repeat
      else
        pOffset = [-2, -1]
        repeat with tSpr in pSprite
          tSpr.flipH = 1
        end repeat
      end if
    end if
  end if
end
