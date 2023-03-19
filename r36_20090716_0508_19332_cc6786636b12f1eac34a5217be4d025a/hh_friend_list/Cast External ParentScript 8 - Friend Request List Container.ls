property pRequestList

on construct me
  pRequestList = [:]
end

on deconstruct me
end

on addRequest me, tRequestData
  if ilk(tRequestData) <> #propList then
    return 0
  end if
  tUserID = string(tRequestData[#userID])
  tPrevIndex = pRequestList.findPos(tUserID)
  if tPrevIndex > 0 then
    pRequestList.deleteAt(tPrevIndex)
  end if
  pRequestList[tUserID] = tRequestData
end

on updateRequest me, tRequestData
  if ilk(tRequestData) <> #propList then
    return 0
  end if
  tUserID = string(tRequestData[#userID])
  if not pRequestList.findPos(tUserID) then
    return 0
  end if
  tRequestProps = pRequestList[tUserID]
  if not voidp(tRequestProps) then
    repeat with tNo = 1 to tRequestData.count
      tProp = tRequestData.getPropAt(tNo)
      tValue = tRequestData[tNo]
      tRequestProps[tProp] = tValue
    end repeat
    pRequestList[tUserID] = tRequestProps.duplicate()
  end if
end

on getRequestByUserID me, tUserID
  tRequest = pRequestList[string(tUserID)]
  if voidp(tRequest) then
    return 0
  else
    return tRequest
  end if
end

on getPendingRequests me
  tPendingList = [:]
  tMaxAmount = getVariable("fr.requests.max.visible")
  repeat with tNo = 1 to pRequestList.count
    tRequest = pRequestList[tNo]
    if (tRequest[#state] = #pending) or (tRequest[#state] = #error) then
      tPendingList[string(tRequest[#userID])] = tRequest
      if tPendingList.count >= tMaxAmount then
        exit repeat
      end if
    end if
  end repeat
  return tPendingList
end
