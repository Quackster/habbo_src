property pMember, pProps, pMemName

on define me, tMemName, tPriority, tProps 
  pMemName = tMemName
  pMember = member(getmemnum(tMemName))
  if pMember.type <> #sound then
    return(error(me, "Sound member not found or not a sound:" && tMemName, #define))
  end if
  pPriority = tPriority
  if listp(tProps) then
    pProps = tProps
  else
    pProps = [:]
  end if
  if (pProps.findPos(#volume) = 0) then
    pProps.setAt(#volume, 255)
  end if
  return TRUE
end

on getProperty me, tProp 
  if (tProp = void()) then
    return FALSE
  end if
  if not listp(pProps) then
    return FALSE
  end if
  return(pProps.getAt(tProp))
end

on getMember me 
  return(pMember)
end

on dump me 
  put("member:" && pMemName && pMember)
  put("props:" && pProps)
end
