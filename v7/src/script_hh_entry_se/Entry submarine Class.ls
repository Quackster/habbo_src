property pSprite, pCount, pFrameCount

on define me, tSprite 
  pSprite = tSprite
  me.reset()
  return TRUE
end

on reset me 
  pSprite.member = getmemnum("se_submarine_anim_0")
  pFrameCount = 1
  pCount = 0
end

on update me 
  tFrameList = [0, 1, 2, 3, 4, 5, 6]
  pCount = (pCount + 1)
  if (1 = pCount > 130 and pCount < 140) then
    if pFrameCount <= count(tFrameList) then
      tImage = getmemnum("se_submarine_anim_" & tFrameList.getAt(pFrameCount))
      pSprite.member = tImage
      pFrameCount = (pFrameCount + 1)
    end if
  else
    if (1 = (pCount = 140)) then
      pFrameCount = count(tFrameList)
    else
      if 1 <> (pCount = 141) then
        if 1 <> (pCount = 143) then
          if 1 <> (pCount = 145) then
            if 1 <> (pCount = 147) then
              if (1 = (pCount = 149)) then
                pSprite.flipH = (random(2) - 1)
              else
                if (1 = pCount > 150 and pCount < 160) then
                  if pFrameCount > 1 then
                    pFrameCount = (pFrameCount - 1)
                    pSprite.member = getmemnum("se_submarine_anim_" & tFrameList.getAt(pFrameCount))
                  end if
                else
                  if (1 = pCount > 160) then
                    me.reset()
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
