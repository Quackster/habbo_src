on enterFrame me 
  if CryCount <> 0 and CryHelp <> void() and CryCount <= count(CryHelp) then
    s = ""
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("cryinguser") & "\r"
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("Unit") & "\r" & "\r"
    s = s & CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("CryMsg") & "\r" & "\r"
    member("hobba_who_field").text = s
    member("hobba_pickedup_field").text = AddTextToField("CryPickedBy") && CryHelp.getProp(CryHelp.getPropAt(CryCount)).getProp("PickedCry")
    member("hobba_alerts_field").text = CryCount & "/" & count(CryHelp)
    updateStage()
  end if
end
