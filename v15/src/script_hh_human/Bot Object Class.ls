on getInfo(me)
  me.setProp(#pInfoStruct, #image, image(1, 1, 8))
  return(me.pInfoStruct)
  exit
end

on action_taked(me)
  me.pCarrying = 1
  call(#doHandWorkRight, me.pPartList, "crr")
  exit
end

on action_gived(me)
  me.pCarrying = 1
  call(#doHandWorkRight, me.pPartList, "crr")
  exit
end