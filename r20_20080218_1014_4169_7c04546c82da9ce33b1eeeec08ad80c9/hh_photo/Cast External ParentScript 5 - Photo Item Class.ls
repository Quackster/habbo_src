on select me
  if threadExists(#photo) then
    tSprites = me.getSprites()
    if not listp(tSprites) then
      return 0
    end if
    if tSprites.count < 1 then
      return 0
    end if
    tloc = tSprites[1].loc
    getThread(#photo).getComponent().openPhoto(me.getID(), tloc[1], tloc[2])
    return 1
  else
    return 0
  end if
end
