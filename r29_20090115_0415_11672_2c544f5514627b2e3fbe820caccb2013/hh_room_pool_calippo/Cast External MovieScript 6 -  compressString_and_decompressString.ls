on compressString str
  strC = EMPTY
  repeat with i = 1 to length(str)
    c = char i of str
    if (c = "%") or ((char i + 1 of str = c) and (char i + 2 of str = c) and (char i + 3 of str = c)) then
      j = i
      repeat while (char j of str = c) or (j = 255)
        j = j + 1
      end repeat
      j = j - i
      strC = strC & "%" & int2hex(j) & c
      i = i + j - 1
      next repeat
    end if
    strC = strC & c
  end repeat
  return strC
end

on decompressString strC
  str = EMPTY
  repeat with i = 1 to length(strC)
    c = char i of strC
    if c = "%" then
      num = hex2int(char i + 1 of strC & char i + 2 of strC)
      d = char i + 3 of strC
      repeat with j = 1 to num
        str = str & d
      end repeat
      i = i + 3
      next repeat
    end if
    str = str & c
  end repeat
  return str
end

on int2hex aint
  digits = "0123456789ABCDEF"
  h = EMPTY
  if aint <= 0 then
    hexstr = "00"
  else
    repeat while aint > 0
      d = aint mod 16
      aint = aint / 16
      hexstr = char d + 1 of digits & hexstr
    end repeat
  end if
  if (hexstr.length mod 2) = 1 then
    hexstr = "0" & hexstr
  end if
  return hexstr
end

on hex2int ahex
  digits = "0123456789ABCDEF"
  base = 1
  tot = 0
  repeat while length(ahex) > 0
    lc = the last char in ahex
    delete char -30000 of ahex
    vl = offset(lc, digits) - 1
    tot = tot + (base * vl)
    base = base * 16
  end repeat
  return tot
end
