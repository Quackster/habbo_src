on getInfo(me)
  return(me.pInfoStruct)
  exit
end

on action_taked(me)
  me.pCarrying = 1
  me.definePartListAction(me.getProp(#pPartListSubSet, "handRight"), "crr")
  exit
end

on action_gived(me)
  me.pCarrying = 1
  me.definePartListAction(me.getProp(#pPartListSubSet, "handRight"), "crr")
  exit
end

on getClass(me)
  return("bot")
  exit
end