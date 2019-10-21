on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  me.removeControllingAvatar()
  return(1)
  exit
end

on removeControllingAvatar(me)
  return(me.getGameSystem().executeGameObjectEvent(me.getProp(#pGameObjectSyncValues, #human_id), #reset_player))
  exit
end