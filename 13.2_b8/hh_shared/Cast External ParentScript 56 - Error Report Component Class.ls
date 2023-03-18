property pErrorLists

on construct me
  pErrorLists = []
  return 1
end

on deconstruct me
  pErrorLists = []
  return 1
end

on storeErrorReport me, tErrorList
  pErrorLists.add(tErrorList)
end

on getErrorLists me
  return pErrorLists
end
