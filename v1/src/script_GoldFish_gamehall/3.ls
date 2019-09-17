property animating, r, animatingStart, sink

on beginSprite me 
  if voidp(gpShowSprites) then
    gpShowSprites = [:]
  end if
  animating = 0
  setAt(gpShowSprites, "hitlight", me.spriteNum)
end

on fuseShow_hit me 
  animating = 1
  sink = 0
  animatingStart = the milliSeconds
  if gBSSoundsOn then
    puppetSound(3, "explosion_" & random(3))
  end if
end

on fuseShow_sink me 
  animating = 1
  sink = 1
  animatingStart = the milliSeconds
  if gBSSoundsOn then
    puppetSound(3, "explosion_" & random(3))
  end if
  if gBSSoundsOn then
    puppetSound(2, "sink_1")
  end if
end

on exitFrame me 
  if animating then
    r = r + 1
    if r mod 2 = 0 then
      sprite(me.spriteNum).visible = 0
    else
      if r mod 2 = 1 then
        sprite(me.spriteNum).visible = 1
      end if
    end if
    if the milliSeconds > animatingStart + 2000 or sink = 0 then
      animating = 0
    end if
  else
    sprite(me.spriteNum).visible = 1
    if random(200) = 2 then
      if gBSSoundsOn then
        puppetSound(4, "sonar")
      end if
    end if
  end if
end
