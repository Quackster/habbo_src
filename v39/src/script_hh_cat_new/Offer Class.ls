property pContent, pPrice, pCode, pName

on construct me 
  pContent = []
  pPrice = [:]
end

on deconstruct me 
  repeat while pContent <= undefined
    tObj = getAt(undefined, undefined)
    removeObject(tObj.getID())
  end repeat
  pContent = []
end

on Initialize me, tdata 
  if ilk(tdata) <> #propList then
    return(error(me, "Invalid input format", #Initialize, #major))
  end if
  pCode = tdata.getaProp(#offercode)
  pName = tdata.getaProp(#offername)
  pPrice = tdata.getaProp(#price)
  pContent = []
  tContent = tdata.getaProp(#content)
  if ilk(tContent) <> #list then
    return(error(me, "Invalid offer content format", #Initialize, #major))
  end if
  if tContent.count = 0 then
    return(error(me, "Content was empty", #Initialize, #minor))
  end if
  repeat while tContent <= undefined
    tProductData = getAt(undefined, tdata)
    tObj = createObject(#random, ["ProductData Class"])
    tObj.Initialize(tProductData)
    pContent.add(tObj)
  end repeat
end

on copy me, tAnotherOffer 
  if not objectp(tAnotherOffer) then
    return(error(me, "Invalid input format", #copy, #major))
  end if
  pCode = tAnotherOffer.getCode()
  pName = tAnotherOffer.getName()
  pPrice = [:]
  pPrice.setAt(#pixels, tAnotherOffer.getPrice(#pixels))
  pPrice.setAt(#credits, tAnotherOffer.getPrice(#credits))
  pContent = []
  i = 1
  repeat while i <= tAnotherOffer.getCount()
    tObj = createObject(#random, ["ProductData Class"])
    tObj.copy(tAnotherOffer.getContent(i))
    pContent.add(tObj)
    i = 1 + i
  end repeat
end

on getCode me 
  return(pCode)
end

on getName me 
  return(pName)
end

on getPrice me, ttype 
  if ttype <> #credits and ttype <> #pixels then
    error(me, "Invalid price type", #getPrice, #major)
    return(0)
  end if
  return(pPrice.getAt(ttype))
end

on getCount me 
  return(pContent.count)
end

on getContent me, tIndex 
  if tIndex < 1 or tIndex > pContent.count then
    return(error(me, "Index out of range", #getContent, #major))
  end if
  return(pContent.getAt(tIndex))
end
