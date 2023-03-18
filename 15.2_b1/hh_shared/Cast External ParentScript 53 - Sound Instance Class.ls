property pMemName, pMember, pProps

on define me, tMemName, tPriority, tProps
  pMemName = tMemName
  pMember = member(getmemnum(tMemName))
  if pMember.type <> #sound then
    return error(me, "Sound member not found or not a sound:" && tMemName, #define, #minor)
  end if
  pPriority = tPriority
  if listp(tProps) then
    pProps = tProps
  else
    pProps = [:]
  end if
  if pProps.findPos(#volume) = 0 then
    pProps[#volume] = 255
  end if
  return 1
end

on getProperty me, tProp
  if tProp = VOID then
    return 0
  end if
  if not listp(pProps) then
    return 0
  end if
  return pProps[tProp]
end

on getMember me
  return pMember
end

on dump me
  put "member:" && pMemName && pMember
  put "props:" && pProps
end
