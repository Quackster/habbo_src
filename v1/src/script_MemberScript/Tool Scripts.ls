on changename startnum, endnum, replaceFrom, replaceTo, cl
  repeat with i = startnum to endnum
    oldName = member(i, cl).name
    newName = stringReplace(oldName, replaceFrom, replaceTo)
    member(i, cl).name = newName
  end repeat
end
