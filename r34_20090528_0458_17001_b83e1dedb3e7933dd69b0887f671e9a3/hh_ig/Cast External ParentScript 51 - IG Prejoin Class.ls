on Initialize me
  me.registerForIGComponentUpdates("GameList")
  return 1
end

on handleUpdate me, tUpdateId, tSenderId
  tService = me.getIGComponent("GameList")
  if tService = 0 then
    return 0
  end if
  if tUpdateId <> tService.getObservedGameId() then
    return 1
  end if
  tRenderObj = getObject(me.getRendererID())
  if tRenderObj <> 0 then
    tRenderObj.render()
  end if
end
