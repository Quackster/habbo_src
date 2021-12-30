on AddTextToField TextID, mem 
  if voidp(mem) then
    mem = "FieldTexts"
  end if
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = "="
  if voidp(gFieldLanguage) then
    gFieldLanguage = [:]
  end if
  if voidp(gFieldLanguage.getaProp(mem)) then
    p = [:]
    text = member(mem).text
    f = 1
    repeat while f <= text.count(#line)
      p.addProp(text.getPropRef(#line, f).getProp(#item, 1), value(text.getPropRef(#line, f).getProp(#item, 2)))
      f = (1 + f)
    end repeat
    addProp(gFieldLanguage, mem, p)
  end if
  FieldMes = ""
  p = getaProp(gFieldLanguage, mem)
  if getaProp(p, TextID & " ") <> void() then
    FieldMes = getaProp(p, TextID & " ")
  else
    if getaProp(p, TextID) <> void() then
      FieldMes = getaProp(p, TextID)
    end if
  end if
  the itemDelimiter = oldItemDelimiter
  if FieldMes <> "" then
    return(FieldMes)
  else
    return(TextID)
  end if
end
