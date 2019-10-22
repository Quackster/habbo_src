property pData, pIGComponentId

on construct me 
  pData = [:]
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on define me, tdata 
  return(me.Refresh(tdata))
end

on Refresh me, tdata 
  if not listp(tdata) then
    return FALSE
  end if
  i = 1
  repeat while i <= tdata.count
    tKey = tdata.getPropAt(i)
    tValue = tdata.getAt(i)
    me.pData.setaProp(tKey, tValue)
    i = (1 + i)
  end repeat
  return TRUE
end

on getProperty me, tKey 
  return(me.pData.getaProp(tKey))
end

on exists me, tKey 
  return(me.pData.findPos(tKey))
end

on setProperty me, tKey, tValue 
  tOldValue = me.pData.getaProp(tKey)
  if (ilk(tOldValue) = #list) then
    if ilk(tValue) <> #list then
      if tOldValue.findPos(tValue) then
        tOldValue.deleteOne(tValue)
      else
        tOldValue.append(tValue)
      end if
      tValue = tOldValue
    end if
  end if
  me.pData.setaProp(tKey, tValue)
  return TRUE
end

on getItemId me 
  return(pData.getaProp(#id))
end

on dump me 
  return(pData)
end

on getIGComponent me, tServiceId 
  towner = me.getOwnerIGComponent()
  if (towner = 0) then
    return FALSE
  end if
  return(towner.getIGComponent(tServiceId))
end

on getOwnerIGComponent me 
  return(getObject(pIGComponentId))
end
