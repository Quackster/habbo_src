property pMaxRipples, pAvailableRipples, pRippleSize, pLocFixRect, pRipples, counter, psourseRect

on beginSprite me 
  pMaxRipples = 10
  pAvailableRipples = []
  f = 1
  repeat while f <= pMaxRipples
    pAvailableRipples.add(f)
    f = (1 + f)
  end repeat
  gWaterSpr = me.spriteNum
  pRipples = [:]
  ptempRemoveList = []
  member(sprite(me.spriteNum).member).image.fill(sprite(me.spriteNum).member.rect, rgb(0, 153, 153))
  pLocFixRect = rect(sprite(gWaterSpr).left, sprite(gWaterSpr).top, sprite(gWaterSpr).left, sprite(gWaterSpr).top)
  psourseRect = member(getmemnum("ripple_1")).rect
  pRippleSize = member(getmemnum("ripple_1")).rect
  counter = 1
end

on NewRipple me, rloc 
  if pAvailableRipples.count > 0 then
    NewRipple = pAvailableRipples.getLast()
    pAvailableRipples.deleteAt(pAvailableRipples.count)
    suhde = rloc
    targetRect = ((pRippleSize + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV)) - pLocFixRect)
    if pRipples.findPos(NewRipple) <> void() then
      pRipples.deleteProp(NewRipple)
    end if
    pRipples.addProp(NewRipple, [rloc, 0, targetRect])
  end if
end

on exitFrame me 
  counter = (counter + 1)
  if counter > 2 then
    counter = 0
  else
    if (counter = 2) then
      if pRipples.count > 0 then
        member(sprite(me.spriteNum).member).image.fill(sprite(me.spriteNum).member.rect, rgb(0, 153, 153))
        f = 1
        repeat while f <= pRipples.count
          prop = pRipples.getPropAt(f)
          anim = pRipples.getProp(prop).getAt(2)
          if anim < 7 then
            anim = (anim + 1)
            targetRect = pRipples.getProp(prop).getAt(3)
            member(sprite(me.spriteNum).member).image.copyPixels(member(getmemnum("ripple_" & anim)).image, targetRect, psourseRect, [#ink:39])
            if (anim = 7) then
              pAvailableRipples.add(prop)
            end if
            pRipples.setProp(prop, [pRipples.getProp(prop).getAt(1), anim, targetRect])
          end if
          f = (1 + f)
        end repeat
      end if
    end if
  end if
end
