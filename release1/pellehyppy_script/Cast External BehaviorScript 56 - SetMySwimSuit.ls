on mouseUp me
  whichPartYouWannaChange = ["ch"]
  s = EMPTY
  repeat with f in whichPartYouWannaChange
    sendAllSprites(#GetMyPartData, f)
    s = s & the result
  end repeat
  put "UPDATE" && "ph_figure=" & s
  sendFuseMsg("UPDATE" && "ph_figure=" & s)
  sendFuseMsg("CLOSE_UIMAKOPPI")
  closeUimaKoppi()
  dontPassEvent()
end
