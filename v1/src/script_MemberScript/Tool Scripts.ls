on changename startnum, endnum, replaceFrom, replaceTo, cl 
  i = startnum
  repeat while i <= endnum
    oldName = member(i, cl).name
    newName = stringReplace(oldName, replaceFrom, replaceTo)
    member(i, cl).name = newName
    i = (1 + i)
  end repeat
end
