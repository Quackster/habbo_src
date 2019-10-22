on Initialize me 
  me.registerForIGComponentUpdates("GameList")
  me.registerForIGComponentUpdates("LevelList")
  return TRUE
end

on handleUpdate me, tUpdateId, tSenderId 
  if (tUpdateId = #owner_of_game) then
    tRenderObj = me.getRenderer()
    if (tRenderObj = 0) then
      return FALSE
    end if
    return(tRenderObj.setViewMode(#info))
  end if
  return(me.renderUI())
end
