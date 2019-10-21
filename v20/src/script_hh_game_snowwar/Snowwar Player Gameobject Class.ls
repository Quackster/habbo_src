on construct me 
  return TRUE
end

on deconstruct me 
  me.removeControllingAvatar()
  return TRUE
end

on removeControllingAvatar me 
  return(me.getGameSystem().executeGameObjectEvent(me.getProp(#pGameObjectSyncValues, #human_id), #reset_player))
end
