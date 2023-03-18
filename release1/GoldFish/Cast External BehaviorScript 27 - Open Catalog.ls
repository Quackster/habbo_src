property catName

on mouseDown me
  global whichIsFirstNow, MaxVisibleIndexButton, openCatalog
  if the movieName contains "private" then
    openCatalog = 1
    whichIsFirstNow = 1
    MaxVisibleIndexButton = 8
    openCatalog(catName)
  else
    beep(1)
  end if
end

on getPropertyDescriptionList me
  return [#catName: [#comment: "catalog name", #format: #string, #default: "basicA"]]
end

on mouseEnter me
  if the movieName contains "private" then
    helpText_setText(AddTextToField("OpenCatalog"))
  else
    helpText_setText(AddTextToField("CatalogWorksOnlyYourOwnRoom"))
  end if
end

on mouseLeave me
  if the movieName contains "private" then
    helpText_empty(AddTextToField("OpenCatalog"))
  else
    helpText_empty(AddTextToField("CatalogWorksOnlyYourOwnRoom"))
  end if
end
