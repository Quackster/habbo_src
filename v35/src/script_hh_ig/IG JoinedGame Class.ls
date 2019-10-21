on Initialize(me)
  me.registerForIGComponentUpdates("GameList")
  me.registerForIGComponentUpdates("LevelList")
  return(1)
  exit
end

on handleUpdate(me, tUpdateId, tSenderId)
  if tUpdateId = #owner_of_game then
    tRenderObj = me.getRenderer()
    if tRenderObj = 0 then
      return(0)
    end if
    return(tRenderObj.setViewMode(#info))
  end if
  return(me.renderUI())
  exit
end