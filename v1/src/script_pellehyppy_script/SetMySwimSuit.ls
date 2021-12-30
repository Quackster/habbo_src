on mouseUp me 
  whichPartYouWannaChange = ["ch"]
  s = ""
  repeat while whichPartYouWannaChange <= 1
    f = getAt(1, count(whichPartYouWannaChange))
    sendAllSprites(#GetMyPartData, f)
    s = s & the result
  end repeat
  put("UPDATE" && "ph_figure=" & s)
  sendFuseMsg("UPDATE" && "ph_figure=" & s)
  sendFuseMsg("CLOSE_UIMAKOPPI")
  closeUimaKoppi()
  dontPassEvent()
end
