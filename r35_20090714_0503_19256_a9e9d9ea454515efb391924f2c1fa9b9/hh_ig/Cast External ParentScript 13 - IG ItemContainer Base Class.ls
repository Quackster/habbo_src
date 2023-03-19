property pIGComponentId, pData

on construct me
  pData = [:]
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on define me, tdata
  return me.Refresh(tdata)
end

on Refresh me, tdata
  if not listp(tdata) then
    return 0
  end if
  repeat with i = 1 to tdata.count
    tKey = tdata.getPropAt(i)
    tValue = tdata[i]
    me.pData.setaProp(tKey, tValue)
  end repeat
  return 1
end

on getProperty me, tKey
  return me.pData.getaProp(tKey)
end

on exists me, tKey
  return me.pData.findPos(tKey)
end

on setProperty me, tKey, tValue
  tOldValue = me.pData.getaProp(tKey)
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
  me.pData.setaProp(tKey, tValue)
  return 1
end

on getItemId me
  return pData.getaProp(#id)
end

on dump me
  return pData
end

on getIGComponent me, tServiceId
  towner = me.getOwnerIGComponent()
  if towner = 0 then
    return 0
  end if
  return towner.getIGComponent(tServiceId)
end

on getOwnerIGComponent me
  return getObject(pIGComponentId)
end
