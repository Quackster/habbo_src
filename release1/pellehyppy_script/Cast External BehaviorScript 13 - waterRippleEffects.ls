property pRipples, pMaxRipples, ptempRemoveList, pLocFixRect, psourseRect, pRippleSize, pAvailableRipples, counter
global gWaterSpr

on beginSprite me
  pMaxRipples = 10
  pAvailableRipples = []
  repeat with f = 1 to pMaxRipples
    pAvailableRipples.add(f)
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
    targetRect = pRippleSize + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV) - pLocFixRect
    if pRipples.findPos(NewRipple) <> VOID then
      pRipples.deleteProp(NewRipple)
    end if
    pRipples.addProp(NewRipple, [rloc, 0, targetRect])
  end if
end

on exitFrame me
  counter = counter + 1
  if counter > 2 then
    counter = 0
  else
    if counter = 2 then
      if pRipples.count > 0 then
        member(sprite(me.spriteNum).member).image.fill(sprite(me.spriteNum).member.rect, rgb(0, 153, 153))
        repeat with f = 1 to pRipples.count
          prop = pRipples.getPropAt(f)
          anim = pRipples.getProp(prop)[2]
          if anim < 7 then
            anim = anim + 1
            targetRect = pRipples.getProp(prop)[3]
            member(sprite(me.spriteNum).member).image.copyPixels(member(getmemnum("ripple_" & anim)).image, targetRect, psourseRect, [#ink: 39])
            if anim = 7 then
              pAvailableRipples.add(prop)
            end if
            pRipples.setProp(prop, [pRipples.getProp(prop)[1], anim, targetRect])
          end if
        end repeat
      end if
    end if
  end if
end
