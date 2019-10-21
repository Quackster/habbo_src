on define(me, tSprite)
  pSprite = tSprite
  me.reset()
  return(1)
  exit
end

on reset(me)
  pSprite.member = getmemnum("se_submarine_anim_0")
  pFrameCount = 1
  pCount = 0
  exit
end

on update(me)
  tFrameList = [0, 1, 2, 3, 4, 5, 6]
  pCount = pCount + 1
  if me = pCount > 130 and pCount < 140 then
    if pFrameCount <= count(tFrameList) then
      tImage = getmemnum("se_submarine_anim_" & tFrameList.getAt(pFrameCount))
      pSprite.member = tImage
      pFrameCount = pFrameCount + 1
    end if
  else
    if me = pCount = 140 then
      pFrameCount = count(tFrameList)
    else
      if me <> pCount = 141 then
        if me <> pCount = 143 then
          if me <> pCount = 145 then
            if me <> pCount = 147 then
              if me = pCount = 149 then
                pSprite.flipH = random(2) - 1
              else
                if me = pCount > 150 and pCount < 160 then
                  if pFrameCount > 1 then
                    pFrameCount = pFrameCount - 1
                    pSprite.member = getmemnum("se_submarine_anim_" & tFrameList.getAt(pFrameCount))
                  end if
                else
                  if me = pCount > 160 then
                    me.reset()
                  end if
                end if
              end if
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end