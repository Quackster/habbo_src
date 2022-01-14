on select me 
  if threadExists(#photo) then
    tloc = me.getSprites().getAt(1).loc
    getThread(#photo).getComponent().openPhoto(me.getID(), tloc.getAt(1), tloc.getAt(2))
    return TRUE
  else
    return FALSE
  end if
end
