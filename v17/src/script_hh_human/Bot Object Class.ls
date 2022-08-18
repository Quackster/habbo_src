on getInfo me
  return me.pInfoStruct
end

on action_taked me
  me.pCarrying = 1
  call(#doHandWorkRight, me.getDefinedPartList(me.pPartListSubSet["handRight"]), "crr")
end

on action_gived me
  me.pCarrying = 1
  call(#doHandWorkRight, me.getDefinedPartList(me.pPartListSubSet["handRight"]), "crr")
end

on getClass me
  return "bot"
end
