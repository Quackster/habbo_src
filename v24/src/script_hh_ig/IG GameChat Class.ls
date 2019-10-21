on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on executeGameChat(me, tdata)
  tSystemState = me.getComponent().getSystemState()
  if me <> #after_game then
    if me = #pre_game then
      executeMessage(#showCustomMessage, [#mode:"CHAT", #id:string(tdata.getaProp(#id)), #message:tdata.getaProp(#message), #loc:point(450, 500)])
    else
      executeMessage(#showChatMessage, "CHAT", string(tdata.getaProp(#id)), tdata.getaProp(#message))
    end if
    return(1)
    exit
  end if
end