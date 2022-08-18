property pSpriteOwnerId, pSprite, pSpriteSd, pConstants, pVelocityTable

on deconstruct me
  pVelocityTable = VOID
  pConstants = VOID
  me.resetTargets()
  me.removeSprites()
  return 1
end

on define me, tdata
  me.SetConstants()
  tGameSystem = getObject(#snowwar_gamesystem)
  pVelocityTable = tGameSystem.GetVelocityTable()
  pSpriteOwnerId = ((tGameSystem.getID() & "_snowball_") & me.getID())
  me.setGameObjectProperty(#gameobject_collisionshape_type, getVariable("snowwar.object_snowball.collisionshape_type"))
  me.setGameObjectProperty(#gameobject_collisionshape_radius, getVariable("snowwar.object_snowball.collisionshape_radius"))
  me.createSprites(tdata[#x], tdata[#y], tdata[#z])
  return 1
end

on calculateFlightPath me, tdata, tTargetX, tTargetY
  me.SetConstants()
  tGameSystem = me.getGameSystem()
  pVelocityTable = tGameSystem.GetVelocityTable()
  tX = tdata.x
  tY = tdata.y
  me.pGameObjectSyncValues[#trajectory] = tdata[#trajectory]
  tDeltaX = ((tTargetX - tX) / 200)
  tDeltaY = ((tTargetY - tY) / 200)
  me.pGameObjectSyncValues[#movement_direction] = tGameSystem.get360AngleFromComponents(tDeltaX, tDeltaY)
  if (tdata[#trajectory] = pConstants.TRAJECTORY_QUICK_THROW) then
    tZ = pConstants.QUICK_THROW_HEIGHT_LEVEL
    me.pGameObjectSyncValues[#time_to_live] = pConstants.QUICK_THROW_TIME_TO_LIVE
  else
    if (tdata[#trajectory] = pConstants.TRAJECTORY_SHORT_LOB) then
      tDistanceToTarget = (tGameSystem.sqrt(((tDeltaX * tDeltaX) + (tDeltaY * tDeltaY))) * 200)
      tZ = pConstants.SHORT_LOB_HEIGHT_LEVEL
      me.pGameObjectSyncValues[#time_to_live] = (tDistanceToTarget / pConstants.SHORT_LOB_VELOCITY)
    else
      if (tdata[#trajectory] = pConstants.TRAJECTORY_LONG_LOB) then
        tDistanceToTarget = (tGameSystem.sqrt(((tDeltaX * tDeltaX) + (tDeltaY * tDeltaY))) * 200)
        tZ = pConstants.LONG_LOB_HEIGHT_LEVEL
        me.pGameObjectSyncValues[#time_to_live] = (tDistanceToTarget / pConstants.LONG_LOB_VELOCITY)
      else
        return 0
      end if
    end if
  end if
  me.pGameObjectSyncValues[#parabola_offset] = (me.pGameObjectSyncValues[#time_to_live] / 2)
  me.createSprites(tX, tY, tZ)
  return 1
end

on calculateFrameMovement me
  if me.pKilled then
    return VOID
  end if
  tLocation3D = me.getLocation()
  me.pGameObjectSyncValues[#time_to_live] = (me.pGameObjectSyncValues[#time_to_live] - 1)
  if (me.pGameObjectSyncValues[#trajectory] = pConstants.TRAJECTORY_QUICK_THROW) then
    tNewX = (tLocation3D.x + ((pVelocityTable.GetBaseVelX(me.pGameObjectSyncValues[#movement_direction]) * pConstants.QUICK_THROW_VELOCITY) / 255))
    tNewY = (tLocation3D.y + ((pVelocityTable.GetBaseVelY(me.pGameObjectSyncValues[#movement_direction]) * pConstants.QUICK_THROW_VELOCITY) / 255))
    if (me.pGameObjectSyncValues[#time_to_live] > pConstants.QUICK_THROW_DESCENT_POINT) then
      tTemp = (pConstants.QUICK_THROW_DESCENT_POINT - me.pGameObjectSyncValues[#parabola_offset])
    else
      tTemp = (me.pGameObjectSyncValues[#time_to_live] - me.pGameObjectSyncValues[#parabola_offset])
    end if
    tNewZ = ((((me.pGameObjectSyncValues[#parabola_offset] * me.pGameObjectSyncValues[#parabola_offset]) - (tTemp * tTemp)) * 4) + pConstants.QUICK_THROW_HEIGHT_LEVEL)
  else
    if (me.pGameObjectSyncValues[#trajectory] = pConstants.TRAJECTORY_SHORT_LOB) then
      tNewX = (tLocation3D.x + ((pVelocityTable.GetBaseVelX(me.pGameObjectSyncValues[#movement_direction]) * pConstants.SHORT_LOB_VELOCITY) / 255))
      tNewY = (tLocation3D.y + ((pVelocityTable.GetBaseVelY(me.pGameObjectSyncValues[#movement_direction]) * pConstants.SHORT_LOB_VELOCITY) / 255))
      tTemp = (me.pGameObjectSyncValues[#time_to_live] - me.pGameObjectSyncValues[#parabola_offset])
      tNewZ = ((((me.pGameObjectSyncValues[#parabola_offset] * me.pGameObjectSyncValues[#parabola_offset]) - (tTemp * tTemp)) * 10) + pConstants.SHORT_LOB_HEIGHT_LEVEL)
    else
      tNewX = (tLocation3D.x + ((pVelocityTable.GetBaseVelX(me.pGameObjectSyncValues[#movement_direction]) * pConstants.LONG_LOB_VELOCITY) / 255))
      tNewY = (tLocation3D.y + ((pVelocityTable.GetBaseVelY(me.pGameObjectSyncValues[#movement_direction]) * pConstants.LONG_LOB_VELOCITY) / 255))
      tTemp = (me.pGameObjectSyncValues[#time_to_live] - me.pGameObjectSyncValues[#parabola_offset])
      tNewZ = ((((me.pGameObjectSyncValues[#parabola_offset] * me.pGameObjectSyncValues[#parabola_offset]) - (tTemp * tTemp)) * 100) + pConstants.LONG_LOB_HEIGHT_LEVEL)
    end if
  end if
  me.setLocation(tNewX, tNewY, tNewZ)
  me.setGameObjectSyncProperty([#x: tNewX, #y: tNewY, #z: tNewZ])
  me.moveSprites(tNewX, tNewY, tNewZ)
  tCollisionWithGroundObject = me.testCollisionWithGround()
  if ((tNewZ < 1) or tCollisionWithGroundObject) then
    playSound("LS-miss")
    return me.Remove()
  end if
  return 1
end

on testCollisionWithGround me
  tLocation3D = me.getLocation()
  if (tLocation3D.z < 1) then
    return 1
  end if
  tTile = me.getGameSystem().gettileatworldcoordinate(tLocation3D.x, tLocation3D.y, tLocation3D.z)
  if (tTile = 0) then
    return 0
  end if
  if (tTile.getOccupiedHeight() > tLocation3D.z) then
    return 1
  end if
  return 0
end

on moveSprites me, tNewX, tNewY, tNewZ
  if (ilk(pSprite) <> #sprite) then
    return 0
  end if
  tWorld = me.getGameSystem().getWorld()
  tloc = tWorld.convertWorldToScreenCoordinate(tNewX, tNewY, tNewZ)
  pSprite.loc = point(tloc[1], tloc[2])
  pSprite.locZ = tloc[3]
  tTile = tWorld.gettileatworldcoordinate(tNewX, tNewY, tNewZ)
  if (tTile = 0) then
    tGroundZ = 0
  else
    tGroundZ = tTile.getOccupiedHeight()
  end if
  tloc = tWorld.convertWorldToScreenCoordinate(tNewX, tNewY, tGroundZ)
  pSpriteSd.loc = point(tloc[1], tloc[2])
  pSpriteSd.locZ = tloc[3]
  return 1
end

on createSprites me, tX, tY, tZ
  me.removeSprites()
  pSprite = sprite(reserveSprite(pSpriteOwnerId))
  pSprite.member = member(getmemnum("snowball"))
  pSpriteSd = sprite(reserveSprite(pSpriteOwnerId))
  pSpriteSd.member = member(getmemnum("snowball_sd"))
  return me.moveSprites(tX, tY, tZ)
end

on removeSprites me
  if (ilk(pSprite) = #sprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if (ilk(pSpriteSd) = #sprite) then
    releaseSprite(pSpriteSd.spriteNum)
  end if
  pSprite = VOID
  pSpriteSd = VOID
  return 1
end

on SetConstants me
  pConstants = [:]
  pConstants[#TRAJECTORY_QUICK_THROW] = 0
  pConstants[#TRAJECTORY_SHORT_LOB] = 1
  pConstants[#TRAJECTORY_LONG_LOB] = 2
  pConstants[#QUICK_THROW_DESCENT_POINT] = getIntVariable("QUICK_THROW_DESCENT_POINT")
  pConstants[#QUICK_THROW_TIME_TO_LIVE] = getIntVariable("QUICK_THROW_TIME_TO_LIVE")
  pConstants[#QUICK_THROW_VELOCITY] = getIntVariable("QUICK_THROW_VELOCITY")
  pConstants[#SHORT_LOB_VELOCITY] = getIntVariable("SHORT_LOB_VELOCITY")
  pConstants[#LONG_LOB_VELOCITY] = getIntVariable("LONG_LOB_VELOCITY")
  pConstants[#QUICK_THROW_HEIGHT_LEVEL] = getIntVariable("QUICK_THROW_HEIGHT_LEVEL")
  pConstants[#SHORT_LOB_HEIGHT_LEVEL] = getIntVariable("SHORT_LOB_HEIGHT_LEVEL")
  pConstants[#LONG_LOB_HEIGHT_LEVEL] = getIntVariable("LONG_LOB_HEIGHT_LEVEL")
  return 1
end
