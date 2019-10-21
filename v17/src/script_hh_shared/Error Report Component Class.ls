property pErrorLists

on construct me 
  pErrorLists = []
  registerMessage(#showErrorMessage, me.getID(), #showErrorMessage)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#showErrorMessage, me.getID())
  pErrorLists = []
  return TRUE
end

on showErrorMessage me, tErrorID, tErrorMessage 
  tErrorList = [:]
  tErrorList.setAt(#errorId, tErrorID)
  tErrorList.setAt(#errorMsg, tErrorMessage)
  me.storeErrorReport(tErrorList)
  me.getInterface().showErrors()
end

on storeErrorReport me, tErrorList 
  pErrorLists.add(tErrorList)
end

on getErrorLists me 
  return(pErrorLists)
end

on clearErrorLists me, tIndex 
  tIndex = min(tIndex, pErrorLists.count)
  i = 1
  repeat while i <= tIndex
    pErrorLists.deleteAt(1)
    i = (1 + i)
  end repeat
end
