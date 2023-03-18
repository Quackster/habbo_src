global gpInteractiveItems

on openGameBoard props
  oldDelim = the itemDelimiter
  the itemDelimiter = ";"
  id = item 1 of props
  class = item 2 of props
  data = line 2 of props
  the itemDelimiter = oldDelim
  gameObject = new(script(class && "ItemClass"), VOID, VOID, id, data)
  open(gameObject)
end

on closeGameBoard props
  if voidp(gpInteractiveItems) then
    return 
  end if
  oldDelim = the itemDelimiter
  the itemDelimiter = ";"
  id = item 1 of props
  class = item 2 of props
  data = line 2 of props
  the itemDelimiter = oldDelim
  o = getaProp(gpInteractiveItems, id)
  if not voidp(o) then
    close(o)
  end if
end
