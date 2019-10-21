on construct(me)
  pUiObjectID = "Credit Furni Redeem"
  return(callAncestor(#construct, [me]))
  exit
end

on deconstruct(me)
  if objectExists(pUiObjectID) then
    removeObject(pUiObjectID)
  end if
  callAncestor(#deconstruct, [me])
  exit
end

on prepare(me, tdata)
  pPrice = tdata.getAt(#stuffdata)
  return(1)
  exit
end

on select(me)
  if the doubleClick and getObject(#session).get("room_owner") then
    me.showRedeemInterface()
  end if
  return(1)
  exit
end

on showRedeemInterface(me)
  if objectExists(pUiObjectID) then
    return(1)
  end if
  createObject(pUiObjectID, "Credit Redeem Confirmation Class")
  if objectExists(pUiObjectID) then
    getObject(pUiObjectID).Init(me.getID(), pPrice)
  end if
  return(1)
  exit
end