global gcatName, gCatalogUrl, gCatalogNetId, gOldFilename, gCatalogPopUp

on openCatalog catName
  gCatalogPopUp = new(script("PopUp Context Class"), 2000010000, 45, 95, point(30, 16))
  displayFrame(gCatalogPopUp, "etus")
end

on closeCatalog
  close(gCatalogPopUp)
  gCatalogPopUp = 0
end
