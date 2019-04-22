on constructSpriteManager()
  return(createManager(#sprite_manager, getClassVariable("sprite.manager.class")))
  exit
end

on deconstructSpriteManager()
  return(removeManager(#sprite_manager))
  exit
end

on getSpriteManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#sprite_manager) then
    return(constructSpriteManager())
  end if
  return(tMgr.getManager(#sprite_manager))
  exit
end

on reserveSprite(tClientID)
  return(getSpriteManager().reserveSprite(tClientID))
  exit
end

on releaseSprite(tSprNum)
  return(getSpriteManager().releaseSprite(tSprNum))
  exit
end

on setEventBroker(tSprNum, tID)
  return(getSpriteManager().setEventBroker(tSprNum, tID))
  exit
end

on removeEventBroker(tSprNum)
  return(getSpriteManager().removeEventBroker(tSprNum))
  exit
end

on printSprites(tCount)
  return(getSpriteManager().print(tCount))
  exit
end

on handlers()
  return([])
  exit
end