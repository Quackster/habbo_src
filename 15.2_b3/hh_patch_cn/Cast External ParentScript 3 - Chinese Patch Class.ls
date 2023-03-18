on construct me
  the romanLingo = 1
  the inlineImeEnabled = 0
  if the platform contains "windows" then
    tLine = getIntVariable("win.font.line", 14)
    tFontMember = member("win_font_chinese")
    setVariable("balloon.margin.offset.v", -1)
  else
    tLine = getIntVariable("mac.font.line", 14)
    tFontMember = member("mac_font_chinese")
    setVariable("balloon.margin.offset.v", -3)
  end if
  tFont = tFontMember.font
  tSize = tFontMember.fontSize
  tui = (the environment).uiLanguage
  tos = (the environment).osLanguage
  if (tui = "Other") and (tos = "Chinese") then
    setVariable("writer.instance.class", string(["Writer Class", "Writer Patch A"]))
  else
    if (tui = "Chinese") and (tos = "Chinese") then
      setVariable("writer.instance.class", string(["Writer Class", "Writer Patch A"]))
    else
      if tos = "Chinese" then
        setVariable("writer.instance.class", string(["Writer Class", "Writer Patch A", "Writer Patch B"]))
      end if
    end if
  end if
  tPlain = getStructVariable("struct.font.plain")
  tPlain.setaProp(#font, tFont)
  tPlain.setaProp(#fontSize, tSize)
  tPlain.setaProp(#lineHeight, tLine)
  setVariable("struct.font.plain", string(tPlain))
  tBold = getStructVariable("struct.font.bold")
  tBold.setaProp(#font, tFont)
  tBold.setaProp(#fontSize, tSize)
  tBold.setaProp(#lineHeight, tLine + 2)
  setVariable("struct.font.bold", string(tBold))
  tItal = getStructVariable("struct.font.italic")
  tItal.setaProp(#font, tFont)
  tItal.setaProp(#fontSize, tSize)
  tItal.setaProp(#lineHeight, tLine)
  setVariable("struct.font.italic", string(tItal))
  tLink = getStructVariable("struct.font.link")
  tLink.setaProp(#font, tFont)
  tLink.setaProp(#fontSize, tSize)
  tLink.setaProp(#lineHeight, tLine)
  setVariable("struct.font.link", string(tLink))
  tTool = getStructVariable("struct.font.tooltip")
  tTool.setaProp(#font, tFont)
  tTool.setaProp(#fontSize, tSize)
  tTool.setaProp(#lineHeight, tLine)
  setVariable("struct.font.tooltip", string(tTool))
  if objectExists(#layout_parser) then
    removeObject(#layout_parser)
  end if
  createObject(#layout_parser, getClassVariable("layout.parser.class"))
  createObject(#string_validator, "String Validator Cls")
  registerMessage(#Initialize, me.getID(), #delayedPatch)
  registerMessage(#BalloonManagerCreated, me.getID(), #patchBalloonText)
  return 1
end

on delayedPatch me
  replaceMember("matik_upp", "matik_upp_jp")
  unregisterMessage(#Initialize, me.getID())
end

on patchBalloonText me, tProps
  tManagerID = tProps[#objectPointer]
  tManagerID.setProperty("SHOUT", #color, rgb(255, 0, 0))
end
