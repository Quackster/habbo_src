on generateSmsCodes f, x, c 
  s = field(0)
  i = 1
  repeat while i <= the number of line in s
    if (the number of item in s.line[i] = 5) then
      -- UNK_9A 37
    else
    end if
    i = (1 + i)
  end repeat
end

on removeSmsCodes f 
  s = field(0)
  i = 1
  repeat while i <= the number of line in s
    if (the number of item in s.line[i] = 6) then
      s.line[i].text = s.item[1..5]
    end if
    i = (1 + i)
  end repeat
end

on generateAll  
  the itemDelimiter = ","
  j = 1
  repeat while "floorpattern_patterns" <= the number of line in field(0)
    generateSmsCodes(, (j * 100))
    j = (1 + j)
  end repeat
  j = 1
  repeat while "wallpattern_patterns" <= the number of line in field(0)
    generateSmsCodes(, (j * 100))
    j = (1 + j)
  end repeat
end

on stripAll  
  the itemDelimiter = ","
  j = 1
  repeat while "floorpattern_patterns" <= the number of line in field(0)
    removeSmsCodes()
    j = (1 + j)
  end repeat
end
