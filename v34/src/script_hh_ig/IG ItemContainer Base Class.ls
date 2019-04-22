on construct(me)
  pData = []
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on define(me, tdata)
  return(me.Refresh(tdata))
  exit
end

on Refresh(me, tdata)
  if not listp(tdata) then
    return(0)
  end if
  i = 1
  repeat while i <= tdata.count
    tKey = tdata.getPropAt(i)
    tValue = tdata.getAt(i)
    me.setaProp(tKey, tValue)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on getProperty(me, tKey)
  return(me.getaProp(tKey))
  exit
end

on exists(me, tKey)
  return(me.findPos(tKey))
  exit
end

on setProperty(me, tKey, tValue)
  tOldValue = me.getaProp(tKey)
  if ilk(tOldValue) = #list then
    if ilk(tValue) <> #list then
      if tOldValue.findPos(tValue) then
        tOldValue.deleteOne(tValue)
      else
        tOldValue.append(tValue)
      end if
      tValue = tOldValue
    end if
  end if
  me.setaProp(tKey, tValue)
  return(1)
  exit
end

on getItemId(me)
  return(pData.getaProp(#id))
  exit
end

on dump(me)
  return(pData)
  exit
end

on getIGComponent(me, tServiceId)
  towner = me.getOwnerIGComponent()
  if towner = 0 then
    return(0)
  end if
  return(towner.getIGComponent(tServiceId))
  exit
end

on getOwnerIGComponent(me)
  return(getObject(pIGComponentId))
  exit
end