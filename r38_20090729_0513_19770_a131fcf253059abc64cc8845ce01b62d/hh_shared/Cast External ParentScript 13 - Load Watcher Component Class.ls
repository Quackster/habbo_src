property pGotProductData, pGotFurniData

on construct me
  pGotProductData = 0
  pGotFurniData = 0
  registerMessage(#productDataReceived, me.getID(), #productData)
  registerMessage(#furnidataReceived, me.getID(), #furniData)
end

on deconstruct me
  unregisterMessage(#productDataReceived, me.getID())
  unregisterMessage(#furnidataReceived, me.getID())
end

on productData me
  pGotProductData = 1
  if pGotFurniData then
    callJavaScriptFunction("clientHeavyInitFinished", string(getClientUpTime()))
  end if
end

on furniData me
  pGotFurniData = 1
  if pGotProductData then
    callJavaScriptFunction("clientHeavyInitFinished", string(getClientUpTime()))
  end if
end
