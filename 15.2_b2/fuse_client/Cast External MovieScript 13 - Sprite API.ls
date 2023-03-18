on constructSpriteManager
  return createManager(#sprite_manager, getClassVariable("sprite.manager.class"))
end

on deconstructSpriteManager
  return removeManager(#sprite_manager)
end

on getSpriteManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#sprite_manager) then
    return constructSpriteManager()
  end if
  return tMgr.getManager(#sprite_manager)
end

on reserveSprite tClientID
  return getSpriteManager().reserveSprite(tClientID)
end

on releaseSprite tSprNum
  return getSpriteManager().releaseSprite(tSprNum)
end

on setEventBroker tSprNum, tid
  return getSpriteManager().setEventBroker(tSprNum, tid)
end

on removeEventBroker tSprNum
  return getSpriteManager().removeEventBroker(tSprNum)
end

on printSprites tCount
  return getSpriteManager().print(tCount)
end
