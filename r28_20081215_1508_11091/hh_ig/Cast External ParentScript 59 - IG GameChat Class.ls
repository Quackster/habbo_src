on construct me
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on executeGameChat me, tdata
  tSystemState = me.getComponent().getSystemState()
  case tSystemState of
    #after_game, #pre_game:
      executeMessage(#showCustomMessage, [#mode: "CHAT", #id: string(tdata.getaProp(#id)), #message: tdata.getaProp(#message), #loc: point(450, 500)])
    otherwise:
      executeMessage(#showChatMessage, "CHAT", string(tdata.getaProp(#id)), tdata.getaProp(#message))
  end case
  return 1
end
