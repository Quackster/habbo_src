property pCache

on construct me 
  pCache = [:]
  return TRUE
end

on parse me, tFieldName 
  if memberExists(tFieldName) then
    if listp(pCache.getAt(tFieldName)) then
      tdata = pCache.getAt(tFieldName)
    else
      if tFieldName contains ".window" then
        tdata = me.parse_window(tFieldName)
        pCache.setAt(tFieldName, tdata)
      else
        if tFieldName contains ".element" then
          tdata = me.parse_element(tFieldName)
          pCache.setAt(tFieldName, tdata)
        else
          if tFieldName contains ".room" then
            tdata = me.parse_visual(tFieldName)
          else
            if tFieldName contains ".visual" then
              tdata = me.parse_visual(tFieldName)
              pCache.setAt(tFieldName, tdata)
            end if
          end if
        end if
      end if
    end if
  else
    return(error(me, "Member not found:" && tFieldName, #parse))
  end if
  return(tdata.duplicate())
end

on parse_window me, tFieldName 
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  tSupportedTags = [#elements:[#open:"<elements>", #close:"</elements>"], #rect:[#open:"<rect>", #close:"</rect>"], #border:[#open:"<border>", #close:"</border>"], #clientrect:[#open:"<clientrect>", #close:"</clientrect>"]]
  tLayDefinition = [:]
  tOpenTagFlag = 0
  tTag = ""
  x = 1
  repeat while x <= tSupportedTags.count
    tOpen = tSupportedTags.getAt(x).open
    tClose = tSupportedTags.getAt(x).close
    tTag = tSupportedTags.getPropAt(x)
    tList = []
    i = 1
    repeat while i <= tdata.count(#line)
      if (tdata.getPropRef(#line, i).getProp(#word, 1) = tOpen) then
        i = (i + 1)
        repeat while i <= tdata.count(#line)
          tLine = tdata.getProp(#line, i)
          if (tLine.getProp(#word, 1) = tClose) then
          else
            tList.add(value(tLine))
            i = (1 + i)
          end if
        end repeat
      end if
      i = (1 + i)
    end repeat
    tLayDefinition.setAt(tTag, tList)
    x = (1 + x)
  end repeat
  tElements = [:]
  repeat while tLayDefinition.getAt(#elements) <= 1
    tElem = getAt(1, count(tLayDefinition.getAt(#elements)))
    if voidp(tElem.getAt(#id)) then
      tSymbol = "null"
    else
      tSymbol = tElem.id
    end if
    if voidp(tElements.getAt(tSymbol)) then
      tElements.setAt(tSymbol, [])
    end if
    tElements.getAt(tSymbol).add(tElem)
  end repeat
  tResMngr = getResourceManager()
  repeat while tLayDefinition.getAt(#elements) <= 1
    tElem = getAt(1, count(tLayDefinition.getAt(#elements)))
    if stringp(tElem.getAt(#txtColor)) then
      tElem.setAt(#txtColor, rgb(tElem.getAt(#txtColor)))
    end if
    if stringp(tElem.getAt(#txtBgColor)) then
      tElem.setAt(#txtBgColor, rgb(tElem.getAt(#txtBgColor)))
    end if
    if voidp(tElem.getAt(#color)) then
      tElem.setAt(#color, "#000000")
    end if
    if voidp(tElem.getAt(#bgColor)) then
      tElem.setAt(#bgColor, "#FFFFFF")
    end if
    tElem.setAt(#color, rgb(tElem.getAt(#color)))
    tElem.setAt(#bgColor, rgb(tElem.getAt(#bgColor)))
    tPalette = tElem.getAt(#palette)
    if stringp(tPalette) then
      if not tResMngr.exists(tPalette && "Duplicate") then
        tPalMemNum = tResMngr.getmemnum(tPalette)
        if tPalMemNum > 0 then
          member(tPalMemNum).duplicate(tResMngr.createMember(tPalette && "Duplicate", #palette))
        else
          tResMngr.createMember(tPalette && "Duplicate", #palette)
          error(me, "Palette member missing:" && tPalette, #parse_window)
        end if
      end if
      tElem.setAt(#palette, tPalette && "Duplicate")
    end if
    if (tElem.getAt(#type) = "text") then
      tFontStruct = getStructVariable("struct.font.plain")
      if voidp(tElem.getAt(#wordWrap)) then
        tElem.setAt(#wordWrap, 1)
      end if
      if voidp(tElem.getAt(#alignment)) then
        tElem.setAt(#alignment, #left)
      end if
      if voidp(tElem.getAt(#font)) then
        tElem.setAt(#font, tFontStruct.getaProp(#font))
      end if
      if voidp(tElem.getAt(#fontSize)) then
        tElem.setAt(#fontSize, tFontStruct.getaProp(#fontSize))
      end if
      if voidp(tElem.getAt(#fontStyle)) then
        tElem.setAt(#fontStyle, tFontStruct.getaProp(#fontStyle))
      end if
      if voidp(tElem.getAt(#txtColor)) then
        tElem.setAt(#txtColor, tFontStruct.getaProp(#color))
      end if
      if voidp(tElem.getAt(#txtBgColor)) then
        tElem.setAt(#txtBgColor, rgb(255, 255, 255))
      end if
      if voidp(tElem.getAt(#fixedLineSpace)) then
        tElem.setAt(#fixedLineSpace, tElem.getAt(#fontSize))
      end if
    end if
    if not voidp(tElem.getAt(#strech)) then
      tElem.setAt(#scaleH, #fixed)
      tElem.setAt(#scaleV, #fixed)
      if (tLayDefinition.getAt(#elements) = #moveH) then
        tElem.setAt(#scaleH, #move)
      else
        if (tLayDefinition.getAt(#elements) = #moveV) then
          tElem.setAt(#scaleV, #move)
        else
          if (tLayDefinition.getAt(#elements) = #strechH) then
            tElem.setAt(#scaleH, #scale)
          else
            if (tLayDefinition.getAt(#elements) = #strechV) then
              tElem.setAt(#scaleV, #scale)
            else
              if (tLayDefinition.getAt(#elements) = #centerH) then
                tElem.setAt(#scaleH, #center)
              else
                if (tLayDefinition.getAt(#elements) = #centerV) then
                  tElem.setAt(#scaleV, #center)
                else
                  if (tLayDefinition.getAt(#elements) = #moveHV) then
                    tElem.setAt(#scaleH, #move)
                    tElem.setAt(#scaleV, #move)
                  else
                    if (tLayDefinition.getAt(#elements) = #strechHV) then
                      tElem.setAt(#scaleH, #scale)
                      tElem.setAt(#scaleV, #scale)
                    else
                      if (tLayDefinition.getAt(#elements) = #centerHV) then
                        tElem.setAt(#scaleH, #center)
                        tElem.setAt(#scaleV, #center)
                      else
                        if (tLayDefinition.getAt(#elements) = #moveHstrechV) then
                          tElem.setAt(#scaleH, #move)
                          tElem.setAt(#scaleV, #scale)
                        else
                          if (tLayDefinition.getAt(#elements) = #moveVstrechH) then
                            tElem.setAt(#scaleH, #scale)
                            tElem.setAt(#scaleV, #move)
                          else
                            if (tLayDefinition.getAt(#elements) = #moveHcenterV) then
                              tElem.setAt(#scaleH, #move)
                              tElem.setAt(#scaleV, #center)
                            else
                              if (tLayDefinition.getAt(#elements) = #moveVcenterH) then
                                tElem.setAt(#scaleH, #center)
                                tElem.setAt(#scaleV, #move)
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
      tElem.deleteProp(#strech)
    end if
  end repeat
  if (tLayDefinition.getAt(#rect).count = 0) then
    tRect = rect(10000, 10000, -10000, -10000)
    repeat while tElements <= 1
      tElement = getAt(1, count(tElements))
      repeat while tElements <= 1
        tItem = getAt(1, count(tElements))
        if tItem.locH < tRect.getAt(1) then
          tRect.setAt(1, tItem.locH)
        end if
        if tItem.locV < tRect.getAt(2) then
          tRect.setAt(2, tItem.locV)
        end if
        if (tItem.locH + tItem.width) > tRect.getAt(3) then
          tRect.setAt(3, (tItem.locH + tItem.width))
        end if
        if (tItem.locV + tItem.height) > tRect.getAt(4) then
          tRect.setAt(4, (tItem.locV + tItem.height))
        end if
      end repeat
    end repeat
    tLayDefinition.getAt(#rect).add(tRect)
    repeat while tElements <= 1
      tElement = getAt(1, count(tElements))
      repeat while tElements <= 1
        tItem = getAt(1, count(tElements))
        tItem.locH = (tItem.locH - tRect.getAt(1))
        tItem.locV = (tItem.locV - tRect.getAt(2))
      end repeat
    end repeat
  else
    tList = tLayDefinition.getAt(#rect).getAt(1)
    tLayDefinition.getAt(#rect).setAt(1, rect(tList.getAt(1), tList.getAt(2), tList.getAt(3), tList.getAt(4)))
  end if
  tOffX = tLayDefinition.getAt(#rect).getAt(1).getAt(1)
  tOffY = tLayDefinition.getAt(#rect).getAt(1).getAt(2)
  tLayDefinition.getAt(#rect).setAt(1, (tLayDefinition.getAt(#rect).getAt(1) - [tOffX, tOffY, tOffX, tOffY]))
  if (tLayDefinition.getAt(#border).count = 0) then
    if tLayDefinition.getAt(#clientrect).count > 0 then
      tClientRect = tLayDefinition.getAt(#clientrect).getAt(1)
      tWinWidth = tLayDefinition.getAt(#rect).getAt(1).getAt(3)
      tWinHeight = tLayDefinition.getAt(#rect).getAt(1).getAt(4)
      tBorder = [tClientRect.getAt(1), tClientRect.getAt(2), (tWinWidth - tClientRect.getAt(3)), (tWinHeight - tClientRect.getAt(4))]
      tLayDefinition.getAt(#border).add(tBorder)
    else
      tLayDefinition.getAt(#border).add([0, 0, 0, 0])
    end if
  end if
  tLayDefinition.setAt(#elements, tElements)
  return(tLayDefinition)
end

on parse_element me, tFieldName 
  tProps = [:]
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  f = 1
  repeat while f <= tdata.count(#line)
    tLine = tdata.getProp(#line, f)
    if tLine.getProp(#char, 1) <> "#" then
      if length(tLine) > 1 then
        tValue = value(tLine)
        tProps.addProp(tValue.getAt(#state), tValue)
      end if
    end if
    f = (1 + f)
  end repeat
  return(tProps)
end

on parse_visual me, tFieldName 
  tdata = member(getResourceManager().getmemnum(tFieldName)).text
  tSupportedTags = [#roomdata:[#open:"<roomdata>", #close:"</roomdata>"], #rect:[#open:"<rect>", #close:"</rect>"], #version:[#open:"<version>", #close:"</version>"], #elements:[#open:"<elements>", #close:"</elements>"]]
  tLayDefinition = [:]
  tOpenTagFlag = 0
  tTag = ""
  x = 1
  repeat while x <= tSupportedTags.count
    tOpen = tSupportedTags.getAt(x).open
    tClose = tSupportedTags.getAt(x).close
    tTag = tSupportedTags.getPropAt(x)
    tList = []
    i = 1
    repeat while i <= tdata.count(#line)
      if (tdata.getPropRef(#line, i).getProp(#word, 1) = tOpen) then
        i = (i + 1)
        repeat while i <= tdata.count(#line)
          if (tdata.getPropRef(#line, i).getProp(#word, 1) = tClose) then
          else
            if not voidp(value(tdata.getProp(#line, i))) then
              tList.add(value(tdata.getProp(#line, i)))
            end if
            i = (1 + i)
          end if
        end repeat
      end if
      i = (1 + i)
    end repeat
    if tList.count > 0 then
      tLayDefinition.setAt(tTag, tList)
    end if
    x = (1 + x)
  end repeat
  if voidp(tLayDefinition.getAt(#version)) then
    error(me, "Old visualizer definition:" && tFieldName, #parse_room)
    repeat while tLayDefinition.getAt(#elements) <= 1
      tElem = getAt(1, count(tLayDefinition.getAt(#elements)))
      if (tElem.getAt(#media) = #field) or (tElem.getAt(#media) = #text) then
        tElem.setAt(#txtColor, tElem.getAt(#color))
        tElem.setAt(#txtBgColor, tElem.getAt(#bgColor))
        tElem.setAt(#color, "#000000")
        tElem.setAt(#bgColor, "#FFFFFF")
      end if
      tElem.deleteProp(#foreColor)
      tElem.deleteProp(#backColor)
    end repeat
  end if
  repeat while tLayDefinition.getAt(#elements) <= 1
    tElem = getAt(1, count(tLayDefinition.getAt(#elements)))
    if voidp(tElem.getAt(#color)) then
      tElem.setAt(#color, "#000000")
    end if
    if voidp(tElem.getAt(#bgColor)) then
      tElem.setAt(#bgColor, "#FFFFFF")
    end if
    if (tElem.getAt(#type) = "button") then
      tElem.setAt(#Active, 1)
    end if
  end repeat
  return([#name:tLayDefinition.getAt(#name), #roomdata:tLayDefinition.getAt(#roomdata), #rect:tLayDefinition.getAt(#rect), #elements:tLayDefinition.getAt(#elements)])
end
