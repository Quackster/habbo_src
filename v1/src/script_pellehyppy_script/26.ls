on mouseUp me 
  whichPartYouWannaChange = ["ch"]
  s = ""
  repeat while whichPartYouWannaChange <= undefined
    f = getAt(undefined, undefined)
    sendAllSprites(#GetMyPartData, f)
    s = s & the result
  end repeat
  put("UPDATE" && "ph_figure=" & s)
  sendFuseMsg("UPDATE" && "ph_figure=" & s)
  sendFuseMsg("CLOSE_UIMAKOPPI")
  closeUimaKoppi()
  dontPassEvent()
end
