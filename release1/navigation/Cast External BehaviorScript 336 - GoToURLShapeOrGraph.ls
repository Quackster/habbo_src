property theUrl

on mouseUp me
  put theUrl
  if voidp(theUrl) then
    theUrl = the moviePath & the movieName
  end if
  JumptoNetPage(theUrl, "_new")
end

on mouseEnter me
  put theUrl
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #theUrl, [#comment: "The url to go", #format: #string, #default: "http://www.sulake.com/"])
  return pList
end
