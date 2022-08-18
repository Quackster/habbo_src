property pmodel, pDelayCounter, pDirection, pSprite, pProps, pOffset

on define me, tSprite, ttype 
  pSprite = tSprite
  pOffset = [0, 0]
  pmodel = "boat_" & ttype
  pDelayCounter = 1
  if (pmodel = "boat_1") then
    pProps = [#left:point(723, 335), #right:point(371, 511), #leftlimit:370, #rightlimit:720]
  else
    if (pmodel = "boat_2") then
      pProps = [#left:point(375, 284), #right:point(215, 500), #leftlimit:500, #rightlimit:275, #turn:510]
    else
      if (pmodel = "boat_3") then
        pProps = [#left:point(314, 230), #right:point(250, 520), #leftlimit:500, #rightlimit:230, #turn:570]
      end if
    end if
  end if
  me.reset()
  return TRUE
end

on reset me 
  if pDelayCounter <= 0 then
    pDelayCounter = (random(8) * 10)
  end if
  pDirection = [#left, #right].getAt(random(2))
  if (pmodel = "boat_1") then
    if (pDirection = #left) then
      pSprite.loc = pProps.getAt(#left)
      pOffset = [-2, 1]
    else
      pSprite.loc = pProps.getAt(#right)
      pOffset = [2, -1]
    end if
  else
    if (pDirection = #left) then
      repeat while pSprite <= 1
        tSpr = getAt(1, count(pSprite))
        tSpr.flipH = 1
        tSpr.loc = pProps.getAt(#left)
      end repeat
      pOffset = [2, 1]
    else
      repeat while pSprite <= 1
        tSpr = getAt(1, count(pSprite))
        tSpr.flipH = 0
        tSpr.loc = pProps.getAt(#right)
      end repeat
      pOffset = [2, -1]
    end if
    pSprite.getAt(2).ink = 41
    pSprite.getAt(2).backColor = (random(150) + 20)
  end if
end

on update me 
  if pDelayCounter > 0 then
    pDelayCounter = (pDelayCounter - 1)
    return TRUE
  end if
  if (pmodel = "boat_1") then
    pSprite.loc = (pSprite.loc + pOffset)
    if (pDirection = #left) and pSprite.locH < pProps.getAt(#leftlimit) or (pDirection = #right) and pSprite.locH > pProps.getAt(#rightlimit) then
      return(me.reset())
    end if
  else
    repeat while pSprite <= 1
      tSpr = getAt(1, count(pSprite))
      tSpr.loc = (tSpr.loc + pOffset)
    end repeat
    if (pDirection = #left) and pSprite.getAt(1).locV > pProps.getAt(#leftlimit) or (pDirection = #right) and pSprite.getAt(1).locV < pProps.getAt(#rightlimit) then
      return(me.reset())
    end if
    if pSprite.getAt(1).locH > pProps.getAt(#turn) then
      if (pDirection = #left) then
        pOffset = [-2, 1]
        repeat while pSprite <= 1
          tSpr = getAt(1, count(pSprite))
          tSpr.flipH = 0
        end repeat
      else
        pOffset = [-2, -1]
        repeat while pSprite <= 1
          tSpr = getAt(1, count(pSprite))
          tSpr.flipH = 1
        end repeat
      end if
    end if
  end if
end
