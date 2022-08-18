on mouseUp me 
  theUrl = CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("url")
  put(theUrl)
  JumptoNetPage(theUrl, "_new")
end
