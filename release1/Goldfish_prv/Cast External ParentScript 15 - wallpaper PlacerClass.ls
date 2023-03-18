property itemType

on new me, titemType, stripId
  itemType = titemType
  sendFuseMsg("FLATPROPERTYBYITEM /wallpaper/" & stripId)
  sendFuseMsg("GETSTRIP" && "new")
  return VOID
end

on setLocation me, x, y, he
end

on die me
end

on updateLocation me
end

on getLocationString me
end

on hide me
end

on show me
end

on hideStripItem me
  return 1
end
