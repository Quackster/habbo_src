on construct me
  return 1
end

on deconstruct me
  me.removeControllingAvatar()
  return 1
end

on removeControllingAvatar me
  return me.getGameSystem().executeGameObjectEvent(me.pGameObjectSyncValues[#human_id], #reset_player)
end
