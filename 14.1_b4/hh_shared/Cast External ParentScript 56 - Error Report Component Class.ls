property pErrorLists

on construct me
  pErrorLists = []
  registerMessage(#showErrorMessage, me.getID(), #showErrorMessage)
  return 1
end

on deconstruct me
  unregisterMessage(#showErrorMessage, me.getID())
  pErrorLists = []
  return 1
end

on showErrorMessage me, tErrorID, tErrorMessage
  tErrorList = [:]
  tErrorList[#errorId] = tErrorID
  tErrorList[#errorMsg] = tErrorMessage
  me.storeErrorReport(tErrorList)
  me.getInterface().showErrors()
end

on storeErrorReport me, tErrorList
  pErrorLists.add(tErrorList)
end

on getErrorLists me
  return pErrorLists
end

on clearErrorLists me, tIndex
  tIndex = min(tIndex, pErrorLists.count)
  repeat with i = 1 to tIndex
    pErrorLists.deleteAt(1)
  end repeat
end
