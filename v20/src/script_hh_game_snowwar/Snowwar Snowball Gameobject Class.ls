property pConstants, pVelocityTable, pSprite, pSpriteSd, pSpriteOwnerId

on deconstruct me 
  pVelocityTable = void()
  pConstants = void()
  me.resetTargets()
  me.removeSprites()
  return(1)
end

on define me, tdata 
  me.SetConstants()
  tGameSystem = getObject(#snowwar_gamesystem)
  pVelocityTable = tGameSystem.GetVelocityTable()
  pSpriteOwnerId = tGameSystem.getID() & "_snowball_" & me.getID()
  me.setGameObjectProperty(#gameobject_collisionshape_type, getVariable("snowwar.object_snowball.collisionshape_type"))
  me.setGameObjectProperty(#gameobject_collisionshape_radius, getVariable("snowwar.object_snowball.collisionshape_radius"))
  me.createSprites(tdata.getAt(#x), tdata.getAt(#y), tdata.getAt(#z))
  return(1)
end

on calculateFlightPath me, tdata, tTargetX, tTargetY 
  me.SetConstants()
  tGameSystem = me.getGameSystem()
  pVelocityTable = tGameSystem.GetVelocityTable()
  tX = tdata.x
  tY = tdata.y
  me.setProp(#pGameObjectSyncValues, #trajectory, tdata.getAt(#trajectory))
  tDeltaX = tTargetX - tX / 200
  tDeltaY = tTargetY - tY / 200
  me.setProp(#pGameObjectSyncValues, #movement_direction, tGameSystem.get360AngleFromComponents(tDeltaX, tDeltaY))
  if tdata.getAt(#trajectory) = pConstants.TRAJECTORY_QUICK_THROW then
    tZ = pConstants.QUICK_THROW_HEIGHT_LEVEL
    me.setProp(#pGameObjectSyncValues, #time_to_live, pConstants.QUICK_THROW_TIME_TO_LIVE)
  else
    if tdata.getAt(#trajectory) = pConstants.TRAJECTORY_SHORT_LOB then
      tDistanceToTarget = tGameSystem.sqrt(tDeltaX * tDeltaX + tDeltaY * tDeltaY) * 200
      tZ = pConstants.SHORT_LOB_HEIGHT_LEVEL
      me.setProp(#pGameObjectSyncValues, #time_to_live, tDistanceToTarget / pConstants.SHORT_LOB_VELOCITY)
    else
      if tdata.getAt(#trajectory) = pConstants.TRAJECTORY_LONG_LOB then
        tDistanceToTarget = tGameSystem.sqrt(tDeltaX * tDeltaX + tDeltaY * tDeltaY) * 200
        tZ = pConstants.LONG_LOB_HEIGHT_LEVEL
        me.setProp(#pGameObjectSyncValues, #time_to_live, tDistanceToTarget / pConstants.LONG_LOB_VELOCITY)
      else
        return(0)
      end if
    end if
  end if
  me.setProp(#pGameObjectSyncValues, #parabola_offset, me.getProp(#pGameObjectSyncValues, #time_to_live) / 2)
  me.createSprites(tX, tY, tZ)
  return(1)
end

on calculateFrameMovement me 
  if me.pKilled then
    return(void())
  end if
  tLocation3D = me.getLocation()
  me.setProp(#pGameObjectSyncValues, #time_to_live, me.getProp(#pGameObjectSyncValues, #time_to_live) - 1)
  if me.getProp(#pGameObjectSyncValues, #trajectory) = pConstants.TRAJECTORY_QUICK_THROW then
    tNewX = tLocation3D.x + pVelocityTable.GetBaseVelX(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.QUICK_THROW_VELOCITY / 255
    tNewY = tLocation3D.y + pVelocityTable.GetBaseVelY(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.QUICK_THROW_VELOCITY / 255
    if me.getProp(#pGameObjectSyncValues, #time_to_live) > pConstants.QUICK_THROW_DESCENT_POINT then
      tTemp = pConstants.QUICK_THROW_DESCENT_POINT - me.getProp(#pGameObjectSyncValues, #parabola_offset)
    else
      tTemp = me.getProp(#pGameObjectSyncValues, #time_to_live) - me.getProp(#pGameObjectSyncValues, #parabola_offset)
    end if
    tNewZ = me.getProp(#pGameObjectSyncValues, #parabola_offset) * me.getProp(#pGameObjectSyncValues, #parabola_offset) - tTemp * tTemp * 4 + pConstants.QUICK_THROW_HEIGHT_LEVEL
  else
    if me.getProp(#pGameObjectSyncValues, #trajectory) = pConstants.TRAJECTORY_SHORT_LOB then
      tNewX = tLocation3D.x + pVelocityTable.GetBaseVelX(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.SHORT_LOB_VELOCITY / 255
      tNewY = tLocation3D.y + pVelocityTable.GetBaseVelY(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.SHORT_LOB_VELOCITY / 255
      tTemp = me.getProp(#pGameObjectSyncValues, #time_to_live) - me.getProp(#pGameObjectSyncValues, #parabola_offset)
      tNewZ = me.getProp(#pGameObjectSyncValues, #parabola_offset) * me.getProp(#pGameObjectSyncValues, #parabola_offset) - tTemp * tTemp * 10 + pConstants.SHORT_LOB_HEIGHT_LEVEL
    else
      tNewX = tLocation3D.x + pVelocityTable.GetBaseVelX(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.LONG_LOB_VELOCITY / 255
      tNewY = tLocation3D.y + pVelocityTable.GetBaseVelY(me.getProp(#pGameObjectSyncValues, #movement_direction)) * pConstants.LONG_LOB_VELOCITY / 255
      tTemp = me.getProp(#pGameObjectSyncValues, #time_to_live) - me.getProp(#pGameObjectSyncValues, #parabola_offset)
      tNewZ = me.getProp(#pGameObjectSyncValues, #parabola_offset) * me.getProp(#pGameObjectSyncValues, #parabola_offset) - tTemp * tTemp * 100 + pConstants.LONG_LOB_HEIGHT_LEVEL
    end if
  end if
  me.setLocation(tNewX, tNewY, tNewZ)
  me.setGameObjectSyncProperty([#x:tNewX, #y:tNewY, #z:tNewZ])
  me.moveSprites(tNewX, tNewY, tNewZ)
  tCollisionWithGroundObject = me.testCollisionWithGround()
  if tNewZ < 1 or tCollisionWithGroundObject then
    playSound("LS-miss")
    return(me.Remove())
  end if
  return(1)
end

on testCollisionWithGround me 
  tLocation3D = me.getLocation()
  if tLocation3D.z < 1 then
    return(1)
  end if
  tTile = me.getGameSystem().gettileatworldcoordinate(tLocation3D.x, tLocation3D.y, tLocation3D.z)
  if tTile = 0 then
    return(0)
  end if
  if tTile.getOccupiedHeight() > tLocation3D.z then
    return(1)
  end if
  return(0)
end

on moveSprites me, tNewX, tNewY, tNewZ 
  if ilk(pSprite) <> #sprite then
    return(0)
  end if
  tWorld = me.getGameSystem().getWorld()
  tloc = tWorld.convertWorldToScreenCoordinate(tNewX, tNewY, tNewZ)
  pSprite.loc = point(tloc.getAt(1), tloc.getAt(2))
  pSprite.locZ = tloc.getAt(3)
  tTile = tWorld.gettileatworldcoordinate(tNewX, tNewY, tNewZ)
  if tTile = 0 then
    tGroundZ = 0
  else
    tGroundZ = tTile.getOccupiedHeight()
  end if
  tloc = tWorld.convertWorldToScreenCoordinate(tNewX, tNewY, tGroundZ)
  pSpriteSd.loc = point(tloc.getAt(1), tloc.getAt(2))
  pSpriteSd.locZ = tloc.getAt(3)
  return(1)
end

on createSprites me, tX, tY, tZ 
  me.removeSprites()
  pSprite = sprite(reserveSprite(pSpriteOwnerId))
  pSprite.member = member(getmemnum("snowball"))
  pSpriteSd = sprite(reserveSprite(pSpriteOwnerId))
  pSpriteSd.member = member(getmemnum("snowball_sd"))
  return(me.moveSprites(tX, tY, tZ))
end

on removeSprites me 
  if ilk(pSprite) = #sprite then
    releaseSprite(pSprite.spriteNum)
  end if
  if ilk(pSpriteSd) = #sprite then
    releaseSprite(pSpriteSd.spriteNum)
  end if
  pSprite = void()
  pSpriteSd = void()
  return(1)
end

on SetConstants me 
  pConstants = [:]
  pConstants.setAt(#TRAJECTORY_QUICK_THROW, 0)
  pConstants.setAt(#TRAJECTORY_SHORT_LOB, 1)
  pConstants.setAt(#TRAJECTORY_LONG_LOB, 2)
  pConstants.setAt(#QUICK_THROW_DESCENT_POINT, getIntVariable("QUICK_THROW_DESCENT_POINT"))
  pConstants.setAt(#QUICK_THROW_TIME_TO_LIVE, getIntVariable("QUICK_THROW_TIME_TO_LIVE"))
  pConstants.setAt(#QUICK_THROW_VELOCITY, getIntVariable("QUICK_THROW_VELOCITY"))
  pConstants.setAt(#SHORT_LOB_VELOCITY, getIntVariable("SHORT_LOB_VELOCITY"))
  pConstants.setAt(#LONG_LOB_VELOCITY, getIntVariable("LONG_LOB_VELOCITY"))
  pConstants.setAt(#QUICK_THROW_HEIGHT_LEVEL, getIntVariable("QUICK_THROW_HEIGHT_LEVEL"))
  pConstants.setAt(#SHORT_LOB_HEIGHT_LEVEL, getIntVariable("SHORT_LOB_HEIGHT_LEVEL"))
  pConstants.setAt(#LONG_LOB_HEIGHT_LEVEL, getIntVariable("LONG_LOB_HEIGHT_LEVEL"))
  return(1)
end
