on openGameBoard props 
  oldDelim = the itemDelimiter
  the itemDelimiter = ";"
  id = props.item[1]
  class = props.item[2]
  Data = props.line[2]
  the itemDelimiter = oldDelim
  gameObject = new(script(class && "ItemClass"), void(), void(), id, Data)
  open(gameObject)
end

on closeGameBoard props 
  if voidp(gpInteractiveItems) then
    return()
  end if
  oldDelim = the itemDelimiter
  the itemDelimiter = ";"
  id = props.item[1]
  class = props.item[2]
  Data = props.line[2]
  the itemDelimiter = oldDelim
  o = getaProp(gpInteractiveItems, id)
  if not voidp(o) then
    close(o)
  end if
end
