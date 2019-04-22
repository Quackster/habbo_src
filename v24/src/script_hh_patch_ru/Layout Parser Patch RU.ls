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
      if tdata.getPropRef(#line, i).getProp(#word, 1) = tOpen then
        i = i + 1
        repeat while i <= tdata.count(#line)
          tLine = tdata.getProp(#line, i)
          if tLine.getProp(#word, 1) = tClose then
          else
            tList.add(value(tLine))
            i = 1 + i
          end if
        end repeat
      end if
      i = 1 + i
    end repeat
    tLayDefinition.setAt(tTag, tList)
    x = 1 + x
  end repeat
  tElements = [:]
  repeat while tLayDefinition.getAt(#elements) <= undefined
    tElem = getAt(undefined, tFieldName)
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
  tResMgr = getResourceManager()
  repeat while tLayDefinition.getAt(#elements) <= undefined
    tElem = getAt(undefined, tFieldName)
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
      if not tResMgr.exists(tPalette && "Duplicate") then
        tPalMemNum = getResourceManager().getmemnum(tPalette)
        if tPalMemNum > 0 then
          member(tPalMemNum).duplicate(tResMgr.createMember(tPalette && "Duplicate", #palette))
        else
          tResMgr.createMember(tPalette && "Duplicate", #palette)
          error(me, "Palette member missing:" && tPalette, #parse_window)
        end if
      end if
      tElem.setAt(#palette, tPalette && "Duplicate")
    end if
    if tElem.getAt(#type) = "text" then
      tStructPlain = getStructVariable("struct.font.plain")
      tStructBold = getStructVariable("struct.font.bold")
      if tElem.getAt(#height) < 12 then
        tElem.setAt(#height, 12)
      end if
      if tElem.getAt(#editable) then
        tElem.setAt(#locV, tElem.getAt(#locV) - 3)
      end if
      if voidp(tElem.getAt(#wordWrap)) then
        tElem.setAt(#wordWrap, 1)
      end if
      if voidp(tElem.getAt(#alignment)) then
        tElem.setAt(#alignment, #left)
      end if
      if voidp(tElem.getAt(#font)) then
        tElem.setAt(#font, tStructPlain.getaProp(#font))
      end if
      if voidp(tElem.getAt(#fontSize)) then
        tElem.setAt(#fontSize, tStructPlain.getaProp(#fontSize))
      end if
      if voidp(tElem.getAt(#fontStyle)) then
        tElem.setAt(#fontStyle, tStructPlain.getaProp(#fontStyle))
      end if
      if voidp(tElem.getAt(#txtColor)) then
        tElem.setAt(#txtColor, tStructPlain.getaProp(#color))
      end if
      if voidp(tElem.getAt(#txtBgColor)) then
        tElem.setAt(#txtBgColor, rgb(255, 255, 255))
      end if
      if the platform contains "windows" then
        tElem.setAt(#fixedLineSpace, getVariable("win.fixedLineSpace"))
        if tElem.getAt(#fontSize) > tElem.getAt(#fixedLineSpace) then
          tElem.setAt(#fixedLineSpace, tElem.getAt(#fontSize) + 3)
        end if
      else
        tElem.setAt(#fixedLineSpace, getVariable("mac.fixedLineSpace"))
      end if
      tSizeMultiplier = tElem.getAt(#fontSize) / 9
      if tLayDefinition.getAt(#elements) = #text then
        tUnderl = tElem.getAt(#fontStyle).getOne(#underline) > 0
        tItalic = tElem.getAt(#fontStyle).getOne(#italic) > 0
      else
        if tLayDefinition.getAt(#elements) = #field then
          tUnderl = tElem.getAt(#fontStyle) contains "underline"
          tItalic = tElem.getAt(#fontStyle) contains "italic"
        else
          tUnderl = 0
          tItalic = 0
        end if
      end if
      if tElem.getAt(#font) = "vb" or tElem.getAt(#font) = "VB" or tElem.getAt(#fontStyle) = [#bold] then
        tElem.setAt(#font, tStructBold.getaProp(#font))
        tElem.setAt(#fontSize, tStructBold.getaProp(#fontSize) * tSizeMultiplier)
        tElem.setAt(#lineHeight, tStructBold.getaProp(#lineHeight))
        tElem.setAt(#fontStyle, tStructBold.getaProp(#fontStyle))
      else
        tElem.setAt(#font, tStructPlain.getaProp(#font))
        tElem.setAt(#fontSize, tStructPlain.getaProp(#fontSize) * tSizeMultiplier)
        tElem.setAt(#lineHeight, tStructPlain.getaProp(#lineHeight))
        tElem.setAt(#fontStyle, tStructPlain.getaProp(#fontStyle))
      end if
      if tUnderl then
        tElem.getAt(#fontStyle).deleteOne(#plain)
        tElem.getAt(#fontStyle).add(#underline)
      end if
      if tItalic then
        tElem.getAt(#fontStyle).deleteOne(#plain)
        tElem.getAt(#fontStyle).add(#italic)
      end if
      if tElem.getAt(#model) = #edit then
        if listp(tElem.getAt(#fontStyle)) then
          tStr = ""
          repeat while tLayDefinition.getAt(#elements) <= undefined
            tStyle = getAt(undefined, tFieldName)
            tStr = tStr & tStyle & ","
          end repeat
          tElem.setAt(#fontStyle, tStr.getProp(#char, 1, length(tStr) - 1))
          if the platform contains "Macintosh" then
            tElem.setAt(#height, tElem.getAt(#height) + 2)
            tElem.setAt(#locV, tElem.getAt(#locV) - 2)
          end if
        end if
      end if
    end if
    if not voidp(tElem.getAt(#strech)) then
      tElem.setAt(#scaleH, #fixed)
      tElem.setAt(#scaleV, #fixed)
      if tLayDefinition.getAt(#elements) = #moveH then
        tElem.setAt(#scaleH, #move)
      else
        if tLayDefinition.getAt(#elements) = #moveV then
          tElem.setAt(#scaleV, #move)
        else
          if tLayDefinition.getAt(#elements) = #strechH then
            tElem.setAt(#scaleH, #scale)
          else
            if tLayDefinition.getAt(#elements) = #strechV then
              tElem.setAt(#scaleV, #scale)
            else
              if tLayDefinition.getAt(#elements) = #centerH then
                tElem.setAt(#scaleH, #center)
              else
                if tLayDefinition.getAt(#elements) = #centerV then
                  tElem.setAt(#scaleV, #center)
                else
                  if tLayDefinition.getAt(#elements) = #moveHV then
                    tElem.setAt(#scaleH, #move)
                    tElem.setAt(#scaleV, #move)
                  else
                    if tLayDefinition.getAt(#elements) = #strechHV then
                      tElem.setAt(#scaleH, #scale)
                      tElem.setAt(#scaleV, #scale)
                    else
                      if tLayDefinition.getAt(#elements) = #centerHV then
                        tElem.setAt(#scaleH, #center)
                        tElem.setAt(#scaleV, #center)
                      else
                        if tLayDefinition.getAt(#elements) = #moveHstrechV then
                          tElem.setAt(#scaleH, #move)
                          tElem.setAt(#scaleV, #scale)
                        else
                          if tLayDefinition.getAt(#elements) = #moveVstrechH then
                            tElem.setAt(#scaleH, #scale)
                            tElem.setAt(#scaleV, #move)
                          else
                            if tLayDefinition.getAt(#elements) = #moveHcenterV then
                              tElem.setAt(#scaleH, #move)
                              tElem.setAt(#scaleV, #center)
                            else
                              if tLayDefinition.getAt(#elements) = #moveVcenterH then
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
  if tLayDefinition.getAt(#rect).count = 0 then
    tRect = rect(10000, 10000, -10000, -10000)
    repeat while tLayDefinition.getAt(#elements) <= undefined
      tElement = getAt(undefined, tFieldName)
      repeat while tLayDefinition.getAt(#elements) <= undefined
        tItem = getAt(undefined, tFieldName)
        if tItem.locH < tRect.getAt(1) then
          tRect.setAt(1, tItem.locH)
        end if
        if tItem.locV < tRect.getAt(2) then
          tRect.setAt(2, tItem.locV)
        end if
        if tItem.locH + tItem.width > tRect.getAt(3) then
          tRect.setAt(3, tItem.locH + tItem.width)
        end if
        if tItem.locV + tItem.height > tRect.getAt(4) then
          tRect.setAt(4, tItem.locV + tItem.height)
        end if
      end repeat
    end repeat
    tLayDefinition.getAt(#rect).add(tRect)
    repeat while tLayDefinition.getAt(#elements) <= undefined
      tElement = getAt(undefined, tFieldName)
      repeat while tLayDefinition.getAt(#elements) <= undefined
        tItem = getAt(undefined, tFieldName)
        tItem.locH = tItem.locH - tRect.getAt(1)
        tItem.locV = tItem.locV - tRect.getAt(2)
      end repeat
    end repeat
  else
    tList = tLayDefinition.getAt(#rect).getAt(1)
    tLayDefinition.getAt(#rect).setAt(1, rect(tList.getAt(1), tList.getAt(2), tList.getAt(3), tList.getAt(4)))
  end if
  tOffX = tLayDefinition.getAt(#rect).getAt(1).getAt(1)
  tOffY = tLayDefinition.getAt(#rect).getAt(1).getAt(2)
  tLayDefinition.getAt(#rect).setAt(1, tLayDefinition.getAt(#rect).getAt(1) - [tOffX, tOffY, tOffX, tOffY])
  if tLayDefinition.getAt(#border).count = 0 then
    if tLayDefinition.getAt(#clientrect).count > 0 then
      tClientRect = tLayDefinition.getAt(#clientrect).getAt(1)
      tWinWidth = tLayDefinition.getAt(#rect).getAt(1).getAt(3)
      tWinHeight = tLayDefinition.getAt(#rect).getAt(1).getAt(4)
      tBorder = [tClientRect.getAt(1), tClientRect.getAt(2), tWinWidth - tClientRect.getAt(3), tWinHeight - tClientRect.getAt(4)]
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
  tdata = member(getmemnum(tFieldName)).text
  f = 1
  repeat while f <= tdata.count(#line)
    tLine = tdata.getProp(#line, f)
    if tLine.getProp(#char, 1) <> "#" then
      if length(tLine) > 1 then
        tValue = value(tLine)
        tProps.addProp(tValue.getAt(#state), tValue)
      end if
    end if
    f = 1 + f
  end repeat
  tStructPlain = getStructVariable("struct.font.plain")
  tStructBold = getStructVariable("struct.font.bold")
  repeat while tProps <= undefined
    tstate = getAt(undefined, tFieldName)
    if listp(tstate.getAt(#text)) then
      if tstate.getAt(#text).getAt(#font) = "vb" or tstate.getAt(#text).getAt(#font) = "VB" or tstate.getAt(#text).getAt(#fontStyle) = [#bold] then
        tstate.getAt(#text).setAt(#font, tStructBold.getaProp(#font))
        tstate.getAt(#text).setAt(#fontSize, tStructBold.getaProp(#fontSize))
        tstate.getAt(#text).setAt(#fontStyle, tStructBold.getaProp(#fontStyle))
      else
        tstate.getAt(#text).setAt(#font, tStructPlain.getaProp(#font))
        tstate.getAt(#text).setAt(#fontSize, tStructPlain.getaProp(#fontSize))
        tstate.getAt(#text).setAt(#fontStyle, tStructPlain.getaProp(#fontStyle))
      end if
      if listp(tstate.getAt(#text).getAt(#fontStyle)) then
        tStr = ""
        repeat while tProps <= undefined
          tStyle = getAt(undefined, tFieldName)
          tStr = tStr & tStyle & ","
        end repeat
        tstate.getAt(#text).setAt(#fontStyle, tStr.getProp(#char, 1, length(tStr) - 1))
      end if
    end if
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
      if tdata.getPropRef(#line, i).getProp(#word, 1) = tOpen then
        i = i + 1
        repeat while i <= tdata.count(#line)
          if tdata.getPropRef(#line, i).getProp(#word, 1) = tClose then
          else
            if not voidp(value(tdata.getProp(#line, i))) then
              tList.add(value(tdata.getProp(#line, i)))
            end if
            i = 1 + i
          end if
        end repeat
      end if
      i = 1 + i
    end repeat
    if tList.count > 0 then
      tLayDefinition.setAt(tTag, tList)
    end if
    x = 1 + x
  end repeat
  tStructPlain = getStructVariable("struct.font.plain")
  tStructBold = getStructVariable("struct.font.bold")
  repeat while tLayDefinition.getAt(#elements) <= undefined
    tElem = getAt(undefined, tFieldName)
    if tElem.getAt(#media) = #field or tElem.getAt(#media) = #text then
      tSizeMultiplier = tElem.getAt(#fontSize) / 9
      if tElem.getAt(#font) = "vb" or tElem.getAt(#font) = "VB" or tElem.getAt(#fontStyle) = [#bold] then
        tElem.setAt(#font, tStructBold.getaProp(#font))
        tElem.setAt(#fontSize, tStructBold.getaProp(#fontSize) * tSizeMultiplier)
        tElem.setAt(#fontStyle, tStructBold.getaProp(#fontStyle))
      else
        tElem.setAt(#font, tStructPlain.getaProp(#font))
        tElem.setAt(#fontSize, tStructPlain.getaProp(#fontSize) * tSizeMultiplier)
        tElem.setAt(#fontStyle, tStructPlain.getaProp(#fontStyle))
      end if
      if tElem.getAt(#media) = #field then
        tElem.setAt(#fontStyle, string(tElem.getAt(#fontStyle).getAt(1)))
      end if
    end if
  end repeat
  repeat while tLayDefinition.getAt(#elements) <= undefined
    tElem = getAt(undefined, tFieldName)
    if voidp(tElem.getAt(#color)) then
      tElem.setAt(#color, "#000000")
    end if
    if voidp(tElem.getAt(#bgColor)) then
      tElem.setAt(#bgColor, "#FFFFFF")
    end if
    if tElem.getAt(#type) = "button" then
      tElem.setAt(#Active, 1)
    end if
  end repeat
  return([#name:tLayDefinition.getAt(#name), #roomdata:tLayDefinition.getAt(#roomdata), #rect:tLayDefinition.getAt(#rect), #elements:tLayDefinition.getAt(#elements)])
end
