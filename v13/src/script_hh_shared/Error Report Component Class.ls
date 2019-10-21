property pErrorLists

on construct me 
  pErrorLists = []
  return TRUE
end

on deconstruct me 
  pErrorLists = []
  return TRUE
end

on storeErrorReport me, tErrorList 
  pErrorLists.add(tErrorList)
end

on getErrorLists me 
  return(pErrorLists)
end
