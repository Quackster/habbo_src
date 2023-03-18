property pOfferList, pSmallPreview, pState

on construct me
  pOfferList = []
  pSmallPreview = VOID
  pState = VOID
end

on deconstruct me
  repeat with tObj in pOfferList
    removeObject(tObj.getID())
  end repeat
  pOfferList = []
end

on add me, tOfferData
  if ilk(tOfferData) <> #propList then
    return error(me, "Invalid input format", #Initialize, #major)
  end if
  tOffer = createObject(#random, ["Offer Class"])
  tOffer.Initialize(tOfferData)
  pOfferList.add(tOffer)
end

on setSmallPreview me, tPrev
  pSmallPreview = tPrev
end

on setState me, tstate
  pState = tstate
end

on getCount me
  return pOfferList.count
end

on getOffer me, tIndex
  if (tIndex < 1) or (tIndex > pOfferList.count) then
    return error(me, "Index out of range", #getOffer, #major)
  end if
  return pOfferList[tIndex]
end

on getSmallPreview me
  return pSmallPreview
end

on getState me
  return pState
end
