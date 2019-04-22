on Initialize(me, tdata)
  if ilk(tdata) <> #propList then
    return(error(me, "Invalid input format", #Initialize, #major))
  end if
  pType = tdata.getaProp(#type)
  pClassid = tdata.getaProp(#classID)
  pExtraParam = tdata.getaProp(#extra_param)
  pProductcount = tdata.getaProp(#productcount)
  pExpiration = tdata.getaProp(#expiration)
  exit
end

on copy(me, tAnother)
  if not objectp(tAnother) then
    return(error(me, "Invalid input format", #copy, #major))
  end if
  pType = tAnother.getType()
  pClassid = tAnother.getClassId()
  pExtraParam = tAnother.getExtraParam()
  pProductcount = tAnother.getProductCount()
  pExpiration = tAnother.getExpiration()
  exit
end

on setExtraParam(me, tExtraParam)
  pExtraParam = tExtraParam
  exit
end

on getType(me)
  return(pType)
  exit
end

on getClassId(me)
  return(pClassid)
  exit
end

on getExtraParam(me)
  return(pExtraParam)
  exit
end

on getProductCount(me)
  return(pProductcount)
  exit
end

on getExpiration(me)
  return(pExpiration)
  exit
end