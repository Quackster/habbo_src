on getInfo me
  me.pInfoStruct[#image] = image(1, 1, 8)
  return me.pInfoStruct
end

on action_taked me
  me.pCarrying = 1
  call(#doHandWorkRight, me.pPartList, "crr")
end

on action_gived me
  me.pCarrying = 1
  call(#doHandWorkRight, me.pPartList, "crr")
end
