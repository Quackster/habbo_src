property itemType, spr, locX, locY, locHe

on new me, titemType
  itemType = titemType
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("TicTacToe_small")
  return me
end

on setLocation me, x, y, he
  locX = x
  locY = y
  locHe = he
end

on die me
  sprMan_releaseSprite(spr)
end

on updateLocation me
  screenLocs = getScreenCoordinate(locX, locY, locHe)
  sprite(spr).locH = screenLocs[1]
  sprite(spr).locV = screenLocs[2]
end

on getLocationString me
  return locX & "," & locY & "," & locHe
end

on hide me
end

on show me
end

on hideStripItem me
  return 1
end
