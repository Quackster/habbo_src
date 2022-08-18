global NavImg, gUnits, FirstVisiblePlace_navi, gNaviP, gPlaceNamesGraph, gPalaceInsideNowGraph

on UpdateNaviWindow
  global Mytop_navi
  if (gUnits <> VOID) then
    ClearPicture("NaviWindow", 251, ((gNaviP.count * 14) + 14))
    MakePicture("Hotel.view", point(5, 0))
    hwMem = member(the number of member "Hotel.view")
    MakePicture("dottedline", point((hwMem.charPosToLoc(hwMem.text.length).locH + 30), 9))
    MakePicture("golink.graph", point(225, 1))
    f = 0
    tFirstLine = (Mytop_navi / 14)
    if (tFirstLine < 1) then
      tFirstLine = 1
    end if
    publicRooms = gNaviP.count
    repeat with i = 1 to publicRooms
      if (gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Visible") = 0) then
        tFirstLine = (tFirstLine + 1)
        next repeat
      end if
      if (i >= tFirstLine) then
        f = (f + 1)
        if not voidp(gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Multiroom")) then
          Myhierarchy = 44
        else
          Myhierarchy = 89
          if (gNaviP.getaProp(gNaviP.getPropAt((i - 1))).getaProp("Main") = 1) then
            MakePicture("subroom_line_first", point((Myhierarchy - 38), ((f * 14) - 2)))
          else
            MakePicture("subroom_line", point((Myhierarchy - 38), ((f * 14) - 6)))
          end if
        end if
        if (value(gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Multiroom")) > 1) then
          if (gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Status") = "Closed") then
            iconMember = "multiroom_icon_closed"
            triangle = "triangle_closed"
            MakePicture(triangle, point((Myhierarchy - 38), (f * 14)))
          end if
          if (gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Status") = "Open") then
            iconMember = "multiroom_icon_closed"
            triangle = "triangle_open"
            MakePicture(triangle, point((Myhierarchy - 38), ((f * 14) + 2)))
          end if
        else
          iconMember = "colored_room_icon"
        end if
        if (getmemnum((("colored_room_icon_" & i) & " palette")) <> -1) then
          member(iconMember, castLib("navigation").number).paletteRef = member(getmemnum((("colored_room_icon_" & i) & " palette")))
        else
          member(iconMember, castLib("navigation").number).paletteRef = member(getmemnum("colored_room_icon_default palette"))
        end if
        MakePicture(iconMember, point((Myhierarchy - 24), (f * 14)))
        MakeImgToPic(gPlaceNamesGraph.getaProp(gNaviP.getPropAt(i)), point(Myhierarchy, (f * 14)))
        startNu = ((Myhierarchy + gPlaceNamesGraph.getaProp(gNaviP.getPropAt(i)).width) - 45)
        if (the platform contains "Mac") then
          startNu = (startNu + 20)
        end if
        MakeImgToPic(gPalaceInsideNowGraph.getaProp(gNaviP.getPropAt(i)), point(startNu, ((f * 14) + 2)))
        if (value(gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Multiroom")) > 0) then
          dline = (startNu + gPalaceInsideNowGraph.getaProp(gNaviP.getPropAt(i)).width)
        else
          dline = ((startNu + gPalaceInsideNowGraph.getaProp(gNaviP.getPropAt(i)).width) - 6)
        end if
        if ((dline mod 2) = 1) then
          dline = (dline + 1)
        end if
        if (value(gNaviP.getaProp(gNaviP.getPropAt(i)).getaProp("Multiroom")) <= 1) then
          MakePicture("dottedline", point(dline, ((f * 14) + 9)), 1)
          MakePicture("golink.graph", point(225, ((f * 14) + 1)))
        end if
      end if
    end repeat
  end if
end

on ClearPicture WhichMember, myWidth, MyHeight
  myWidth = 251
  MyHeight = 182
  NavImg = image(myWidth, MyHeight, 16)
  NavImg.fill(rect(0, 0, myWidth, MyHeight), rgb(239, 239, 239))
end

on ResetNavigationWindow
  EmptyImg = image(251, 182, 16)
  member("VisibleNaviWindow").image = EmptyImg
  member("VisibleNaviWindow").image.fill(rect(0, 0, member("VisibleNaviWindow").width, member("VisibleNaviWindow").height), rgb(239, 239, 239))
  imMem = member(the number of member "LOADINGNAVIGATION")
  suhde = point(105, 80)
  targetRect = (imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV))
  sourseRect = imMem.rect
  member("VisibleNaviWindow").image.copyPixels(imMem.image, targetRect, sourseRect)
end

on CropEmpty WhichMember, area
  member(WhichMember).image.fill(area, rgb(255, 255, 255))
end

on MakeImgToPic imMem, StartPoint, Myink, imagForeColor, imagBackColor, MyBlendLevel
  suhde = StartPoint
  targetRect = (imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV))
  sourseRect = imMem.rect
  if (Myink = VOID) then
    Myink = 0
  end if
  if (imagBackColor = VOID) then
    imagBackColor = rgb(255, 255, 255)
  end if
  if (imagForeColor = VOID) then
    imagForeColor = rgb(0, 0, 0)
  end if
  if (MyBlendLevel = VOID) then
    MyBlendLevel = 255
  end if
  NavImg.copyPixels(imMem, targetRect, sourseRect, [#ink: Myink, #bgColor: imagBackColor, #color: imagForeColor, #blendLevel: MyBlendLevel])
end

on MakePicture WhichMember, StartPoint, Myink, imagForeColor, imagBackColor, MyBlendLevel
  imMem = member(the number of member WhichMember)
  suhde = StartPoint
  targetRect = (imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV))
  sourseRect = imMem.rect
  if (Myink = VOID) then
    Myink = 0
  end if
  if (imagBackColor = VOID) then
    imagBackColor = rgb(255, 255, 255)
  end if
  if (imagForeColor = VOID) then
    imagForeColor = rgb(0, 0, 0)
  end if
  if (MyBlendLevel = VOID) then
    MyBlendLevel = 255
  end if
  NavImg.copyPixels(imMem.image, targetRect, sourseRect, [#ink: Myink, #bgColor: imagBackColor, #color: imagForeColor, #blendLevel: MyBlendLevel])
end

on MakeImgToImg targetImag, imMem, StartPoint, Myink, imagForeColor, imagBackColor, MyBlendLevel
  suhde = StartPoint
  targetRect = (imMem.rect + rect(suhde.locH, suhde.locV, suhde.locH, suhde.locV))
  sourseRect = imMem.rect
  if (Myink = VOID) then
    Myink = 0
  end if
  if (imagBackColor = VOID) then
    imagBackColor = rgb(255, 255, 255)
  end if
  if (imagForeColor = VOID) then
    imagForeColor = rgb(0, 0, 0)
  end if
  if (MyBlendLevel = VOID) then
    MyBlendLevel = 255
  end if
  targetImag.copyPixels(imMem, targetRect, sourseRect, [#ink: Myink, #bgColor: imagBackColor, #color: imagForeColor, #blendLevel: MyBlendLevel])
  return targetImag
end
