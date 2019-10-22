on Initialize me 
  me.registerForIGComponentUpdates("GameList")
  return TRUE
end

on handleUpdate me, tUpdateId, tSenderId 
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  if tUpdateId <> tService.getObservedGameId() then
    return TRUE
  end if
  tRenderObj = getObject(me.getRendererID())
  if tRenderObj <> 0 then
    tRenderObj.render()
  end if
end
