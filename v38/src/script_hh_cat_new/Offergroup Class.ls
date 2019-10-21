on construct(me)
  pOfferList = []
  pSmallPreview = void()
  pState = void()
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tObj = getAt(undefined, undefined)
    removeObject(tObj.getID())
  end repeat
  pOfferList = []
  exit
end

on add(me, tOfferData)
  if ilk(tOfferData) <> #propList then
    return(error(me, "Invalid input format", #Initialize, #major))
  end if
  tOffer = createObject(#random, ["Offer Class"])
  tOffer.Initialize(tOfferData)
  pOfferList.add(tOffer)
  exit
end

on setSmallPreview(me, tPrev)
  pSmallPreview = tPrev
  exit
end

on setState(me, tstate)
  pState = tstate
  exit
end

on getCount(me)
  return(pOfferList.count)
  exit
end

on getOffer(me, tIndex)
  if tIndex < 1 or tIndex > pOfferList.count then
    return(error(me, "Index out of range", #getOffer, #major))
  end if
  return(pOfferList.getAt(tIndex))
  exit
end

on getSmallPreview(me)
  return(pSmallPreview)
  exit
end

on getState(me)
  return(pState)
  exit
end