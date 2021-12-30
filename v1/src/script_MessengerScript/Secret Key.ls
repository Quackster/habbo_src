on secretDecode key 
  put(key.length)
  put(key)
  l = key.length
  if ((l mod 2) = 1) then
    l = (l - 1)
  end if
  table = key.char[1..(key.length / 2)]
  key = key.char[(1 + (key.length / 2))..l]
  put(key.length && table.length)
  checkSum = 0
  i = 1
  repeat while i <= key.length
    c = key.char[i]
    a = (offset(c, table) - 1)
    if ((a mod 2) = 0) then
      a = (a * 2)
    end if
    if (((i - 1) mod 3) = 0) then
      a = (a * 3)
    end if
    if a < 0 then
      a = (key.length mod 2)
    end if
    checkSum = (checkSum + a)
    i = (1 + i)
  end repeat
  put(checkSum)
  return(checkSum)
end
