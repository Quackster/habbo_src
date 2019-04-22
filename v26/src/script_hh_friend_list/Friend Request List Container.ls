on construct(me)
  pRequestList = []
  exit
end

on deconstruct(me)
  exit
end

on addRequest(me, tRequestData)
  if ilk(tRequestData) <> #propList then
    return(0)
  end if
  tUserID = string(tRequestData.getAt(#userID))
  tPrevIndex = pRequestList.findPos(tUserID)
  if tPrevIndex > 0 then
    pRequestList.deleteAt(tPrevIndex)
  end if
  pRequestList.setAt(tUserID, tRequestData)
  exit
end

on updateRequest(me, tRequestData)
  if ilk(tRequestData) <> #propList then
    return(0)
  end if
  tUserID = string(tRequestData.getAt(#userID))
  if not pRequestList.findPos(tUserID) then
    return(0)
  end if
  tRequestProps = pRequestList.getAt(tUserID)
  if not voidp(tRequestProps) then
    tNo = 1
    repeat while tNo <= tRequestData.count
      tProp = tRequestData.getPropAt(tNo)
      tValue = tRequestData.getAt(tNo)
      tRequestProps.setAt(tProp, tValue)
      tNo = 1 + tNo
    end repeat
    pRequestList.setAt(tUserID, tRequestProps.duplicate())
  end if
  exit
end

on getRequestByUserID(me, tUserID)
  tRequest = pRequestList.getAt(string(tUserID))
  if voidp(tRequest) then
    return(0)
  else
    return(tRequest)
  end if
  exit
end

on getPendingRequests(me)
  tPendingList = []
  tMaxAmount = getVariable("fr.requests.max.visible")
  tNo = 1
  repeat while tNo <= pRequestList.count
    tRequest = pRequestList.getAt(tNo)
    if tRequest.getAt(#state) = #pending or tRequest.getAt(#state) = #error then
      tPendingList.setAt(string(tRequest.getAt(#userID)), tRequest)
      if tPendingList.count >= tMaxAmount then
      else
        tNo = 1 + tNo
      end if
      return(tPendingList)
      exit
    end if
  end repeat
end

on cleanUpHandled(me)
  tNo = 1
  repeat while tNo <= pRequestList.count
    tRequest = pRequestList.getAt(tNo)
    if tRequest.getAt(#status) = #rejected or tRequest.getAt(#status) = #accepted then
      pRequestList.deleteAt(tNo)
    end if
    tNo = 1 + tNo
  end repeat
  exit
end