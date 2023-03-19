property pUiObjectID, pPrice

on construct me
  pUiObjectID = "Credit Furni Redeem"
  return callAncestor(#construct, [me])
end

on deconstruct me
  if objectExists(pUiObjectID) then
    removeObject(pUiObjectID)
  end if
  callAncestor(#deconstruct, [me])
end

on prepare me, tdata
  pPrice = tdata[#stuffdata]
  return 1
end

on select me
  if the doubleClick and getObject(#session).GET("room_owner") then
    me.showRedeemInterface()
  end if
  return 1
end

on showRedeemInterface me
  if objectExists(pUiObjectID) then
    return 1
  end if
  createObject(pUiObjectID, "Credit Redeem Confirmation Class")
  if objectExists(pUiObjectID) then
    getObject(pUiObjectID).Init(me.getID(), pPrice)
  end if
  return 1
end
