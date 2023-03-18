on mouseUp me
  global CryHelp, CryCount
  theUrl = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("url")
  put theUrl
  JumptoNetPage(theUrl, "_new")
end
