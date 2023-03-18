on generateSmsCodes f, x, c
  s = field(f)
  repeat with i = 1 to the number of lines in s
    if the number of items in line i of s = 5 then
      put "," & c & x + i after line i of s
      next repeat
    end if
    put item 1 to 5 of line i of s & "," & c & x + i into line i of s
  end repeat
  put s into field f
end

on removeSmsCodes f
  s = field(f)
  repeat with i = 1 to the number of lines in s
    if the number of items in line i of s = 6 then
      (line i of s).text = item 1 to 5 of line i of s
    end if
  end repeat
  put s into field f
end

on generateAll
  the itemDelimiter = ","
  repeat with j = 1 to the number of lines in field "floorpattern_patterns"
    generateSmsCodes(line j of field "floorpattern_patterns", j * 100)
  end repeat
  repeat with j = 1 to the number of lines in field "wallpattern_patterns"
    generateSmsCodes(line j of field "wallpattern_patterns", j * 100)
  end repeat
end

on stripAll
  the itemDelimiter = ","
  repeat with j = 1 to the number of lines in field "floorpattern_patterns"
    removeSmsCodes(line j of field "floorpattern_patterns")
  end repeat
end
