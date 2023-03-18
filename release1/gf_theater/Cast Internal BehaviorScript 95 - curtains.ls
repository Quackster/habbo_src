property curtainsState, name, curtainsMoveTimes
global gpShowSprites

on animateCurtains
  if curtainsState = VOID then
    curtainsMoveTimes = 0
    return 
  else
    if curtainsState = 0 then
      curtainsMoveTimes = 0
      return 
    end if
  end if
  if curtainsState = 1 then
    curtainsMoveTimes = curtainsMoveTimes + 1
    hoax = "curtain" & 4 - curtainsMoveTimes
    hoax2 = "curtain" & 4 - curtainsMoveTimes & "r"
    set the member of sprite 10 to member(hoax)
    set the member of sprite 11 to member(hoax2)
    put sprite(10).locZ
    if curtainsMoveTimes > 2 then
      curtainsMoveTimes = 0
      curtainsState = 0
    end if
  end if
  if curtainsState = 2 then
    curtainsMoveTimes = curtainsMoveTimes + 1
    hoax = "curtain" & 1 + curtainsMoveTimes
    hoax2 = "curtain" & 1 + curtainsMoveTimes & "r"
    set the member of sprite 10 to member(hoax)
    set the member of sprite 11 to member(hoax2)
    if curtainsMoveTimes > 2 then
      curtainsMoveTimes = 0
      curtainsState = 0
    end if
  end if
end

on beginSprite me
  if gpShowSprites = VOID then
    gpShowSprites = [:]
  end if
  name = "curtains"
  setaProp(gpShowSprites, name, me.spriteNum)
  curtainsState = 2
end

on fuseShow_open me
  if curtainsState = 1 then
    return 
  end if
  curtainsState = 1
end

on fuseShow_close me
  curtainsState = 2
end
