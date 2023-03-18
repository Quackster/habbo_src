on MyWireFace FigureData, FaceMember, small
  if voidp(FigureData) or voidp(FaceMember) then
    return 
  end if
  if voidp(getaProp(FigureData, #hd)) then
    return 
  end if
  faceParts = []
  if voidp(small) or (small = 0) then
    faceParts = ["hd", "ey", "fc", "hr"]
  else
    faceParts = ["hd", "fc", "hr"]
  end if
  myImage = image(100, 100, 8)
  member(FaceMember).image = myImage
  member(FaceMember).centerRegPoint = 1
  if voidp(small) or (small = 0) then
    paa = "h_std_hd_" & getaProp(FigureData, #hd) & "_3_0"
  else
    paa = "sh_std_hd_" & getaProp(FigureData, #hd) & "_3_0"
  end if
  repeat with f in faceParts
    if voidp(small) or (small = 0) then
      kuva = "h_std_" & f & "_" & getaProp(FigureData, f) & "_3_0"
    else
      kuva = "sh_std_" & f & "_" & getProp(FigureData, f) & "_3_0"
    end if
    suhde = member(paa).regPoint + point(member(FaceMember).width / 2, member(FaceMember).height / 2) - member(kuva).regPoint
    targetRect = member(kuva).rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV)
    sourseRect = member(kuva).rect
    faceColor = rgb(0, 0, 0)
    case f of
      "hd", "fc", "hr":
        member(FaceMember).image.copyPixels(member(kuva).image, targetRect, sourseRect, [#maskImage: member(kuva).image.createMatte(), #ink: 8, #color: faceColor])
      "ey":
        member(FaceMember).image.copyPixels(member(kuva).image, targetRect, sourseRect, [#ink: 36])
      otherwise:
        nothing()
    end case
  end repeat
  myImage = member(FaceMember).image
  myImage = myImage.trimWhiteSpace()
  member(FaceMember).image = myImage
end

on FigureDataParser FigureData
  PartList = [:]
  ColorList = [:]
  PartList = keyValueToPropList(FigureData, "&")
  put PartList
  oldDelim = the itemDelimiter
  repeat with i = 1 to count(PartList)
    model = getAt(PartList, i)
    the itemDelimiter = "/"
    setAt(PartList, i, item 1 of model)
    the itemDelimiter = oldDelim
  end repeat
  return PartList
end
