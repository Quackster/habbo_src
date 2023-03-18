on construct me
  the romanLingo = 1
  the inlineImeEnabled = 1
  if the platform contains "windows" then
    tFont = getVariable("win.font.name", "Arial CYR")
    tSize = getIntVariable("win.font.size", 11)
    tLine = getIntVariable("win.font.line", 11)
  else
    tFont = getVariable("mac.font.name", "Lucida Grande CY")
    tSize = getIntVariable("mac.font.size", 11)
    tLine = getIntVariable("mac.font.line", 11)
  end if
  tui = (the environment).uiLanguage
  tos = (the environment).osLanguage
  setVariable("writer.instance.class", string(["Writer Class", "Writer Patch A"]))
  tPlain = getStructVariable("struct.font.plain")
  tPlain.setaProp(#font, tFont)
  tPlain.setaProp(#fontSize, tSize)
  tPlain.setaProp(#lineHeight, tLine)
  setVariable("struct.font.plain", string(tPlain))
  tBold = getStructVariable("struct.font.bold")
  tBold.setaProp(#font, tFont)
  tBold.setaProp(#fontSize, tSize)
  tBold.setaProp(#lineHeight, tLine)
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
