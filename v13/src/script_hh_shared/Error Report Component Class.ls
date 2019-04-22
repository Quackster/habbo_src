on construct(me)
  pErrorLists = []
  return(1)
  exit
end

on deconstruct(me)
  pErrorLists = []
  return(1)
  exit
end

on storeErrorReport(me, tErrorList)
  pErrorLists.add(tErrorList)
  exit
end

on getErrorLists(me)
  return(pErrorLists)
  exit
end