property tmpEyes, isGirlEyes, allGirlEyes, isGirl
global figurePartList

on exitFrame me
  isGirl = 0
  tmpEyes = figurePartList.ey
  the itemDelimiter = "="
  isGirlEyes = integer(tmpEyes.item[2])
  put "isGirlEyes" && isGirlEyes
  allGirlEyes = []
  the itemDelimiter = ","
  repeat with c = 1 to field("hd_specs_female").line.count
    allGirlEyes.add(field("hd_specs_female").line[c].item[2])
  end repeat
  put allGirlEyes && "allGirlEyes"
  repeat with c = 1 to allGirlEyes.count
    if isGirlEyes = allGirlEyes[c] then
      isGirl = 1
    end if
  end repeat
  if isGirl then
    put "Female" into field "charactersex_field"
  else
    put "Male" into field "charactersex_field"
  end if
  put "is this silly character a girl" && isGirl
end
