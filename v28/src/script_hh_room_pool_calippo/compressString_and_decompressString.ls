on compressString str 
  strC = ""
  i = 1
  repeat while i <= length(str)
    c = str.char[i]
    if c = "%" or str.char[i + 1] = c and str.char[i + 2] = c and str.char[i + 3] = c then
      j = i
      repeat while str.char[j] = c or j = 255
        j = j + 1
      end repeat
      j = j - i
      strC = strC & "%" & int2hex(j) & c
      i = i + j - 1
    else
      strC = strC & c
    end if
    i = 1 + i
  end repeat
  return(strC)
end

on decompressString strC 
  str = ""
  i = 1
  repeat while i <= length(strC)
    c = strC.char[i]
    if c = "%" then
      num = hex2int(strC.char[i + 1] & strC.char[i + 2])
      d = strC.char[i + 3]
      j = 1
      repeat while j <= num
        str = str & d
        j = 1 + j
      end repeat
      i = i + 3
    else
      str = str & c
    end if
    i = 1 + i
  end repeat
  return(str)
end

on int2hex aint 
  digits = "0123456789ABCDEF"
  h = ""
  if aint <= 0 then
    hexstr = "00"
  else
    repeat while aint > 0
      d = (aint mod 16)
      aint = (aint / 16)
      hexstr = digits.char[d + 1] & hexstr
    end repeat
  end if
  if (hexstr.length mod 2) = 1 then
    hexstr = "0" & hexstr
  end if
  return(hexstr)
end

on hex2int ahex 
  digits = "0123456789ABCDEF"
  base = 1
  tot = 0
  repeat while length(ahex) > 0
    lc = the last char in ahex
    vl = offset(lc, digits) - 1
    tot = tot + (base * vl)
    base = (base * 16)
  end repeat
  return(tot)
end
