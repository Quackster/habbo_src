property spr, direction, x1, y1, y2, x2, size

on new me, tsize 
  size = integer(tsize)
  return(me)
end

on endSprite me 
  sprMan_releaseSprite(spr)
end

on hide me 
  sprite(spr).visible = 0
  put("hide", spr)
end

on show me 
  sprite(spr).visible = 1
  put("show", spr)
end

on exitFrame me 
  locate(me)
end

on isMySector me, x, y 
  if (direction = #vertical) then
    if (x = x1) and y >= y1 and y <= y2 then
      return TRUE
    end if
  else
    if (direction = #horizontal) then
      if (y = y1) and x >= x1 and x <= x2 then
        return TRUE
      end if
    end if
  end if
  return FALSE
end

on place me, dir, x, y 
  direction = dir
  if (dir = #vertical) then
    x1 = x
    y1 = y
    x2 = x
    y2 = ((y + size) - 1)
  else
    if (dir = #horizontal) then
      x1 = x
      y1 = y
      x2 = ((x1 + size) - 1)
      y2 = y
    end if
  end if
  sendItemMessage(gBattleShip, "PLACESHIP" && size && x1 && y1 && x2 && y2)
  put("PLACESHIP" && size && x1 && y1 && x2 && y2)
  spr = sprite(sprMan_getPuppetSprite())
  put(spr)
  spr.locZ = (sprite(gBSBoardSprite).locZ + 1)
  spr.castNum = getmemnum("bs_ship_" & size & "_" & string(dir).char[1])
  spr.ink = 36
  spr.blend = 80
  spr.scriptInstanceList = [me]
  nextShip(gBattleShip)
end

on locate me 
  spr.locH = ((sprite(gBSBoardSprite).left + 6) + (19 * x1))
  spr.locV = ((sprite(gBSBoardSprite).top + 4) + (19 * y1))
end
