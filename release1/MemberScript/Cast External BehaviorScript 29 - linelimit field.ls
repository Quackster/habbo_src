property maxlines

on exitFrame me
  name = member(the member of sprite me.spriteNum).name
  if the number of lines in field name > maxlines then
    put line 1 to maxlines of field name into field name
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #maxlines, [#comment: "Max number of lines", #format: #integer, #default: 2])
  return pList
end
