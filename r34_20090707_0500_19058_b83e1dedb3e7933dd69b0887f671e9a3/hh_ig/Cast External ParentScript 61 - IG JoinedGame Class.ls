on Initialize me
  me.registerForIGComponentUpdates("GameList")
  me.registerForIGComponentUpdates("LevelList")
  return 1
end

on handleUpdate me, tUpdateId, tSenderId
  if tUpdateId = #owner_of_game then
    tRenderObj = me.getRenderer()
    if tRenderObj = 0 then
      return 0
    end if
    return tRenderObj.setViewMode(#Info)
  end if
  return me.renderUI()
end
