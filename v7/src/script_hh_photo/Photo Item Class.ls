on select me
  if threadExists(#photo) then
    tloc = me.getSprites()[1].loc
    getThread(#photo).getComponent().openPhoto(me.getID(), tloc[1], tloc[2])
    return 1
  else
    return 0
  end if
end
