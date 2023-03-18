property location, data, owner, spr, id, itemType
global gpInteractiveItems, gpObjects, gChosenStuffId, gChosenStuffSprite, gChosenStuffType

on new me, towner, tlocation, tid, tdata
  id = tid
  owner = towner
  location = tlocation
  data = tdata
  if voidp(gpInteractiveItems) then
    gpInteractiveItems = [:]
  end if
  Initialize(me)
  return me
end

on Initialize me
  put "anc. initialize"
end

on processItemMessage me, content
  put content
end

on sendItemMessage me, content
  sendFuseMsg("IIM" && me.id && content)
end

on die me
  deleteProp(gpInteractiveItems, id)
end

on select me
  global hiliter
  gChosenStuffId = id
  gChosenStuffSprite = me.spriteNum
  gChosenStuffType = #item
  setInfoTexts(me)
end

on setInfoTexts me
  global gInfofieldIconSprite, gpUiButtons, gMyName
  sendSprite(gInfofieldIconSprite, #setIcon, me.itemType)
  member("item.info_name").text = me.itemType
  member("item.info_text").text = EMPTY
  if listp(gpUiButtons) and (the movieName contains "private") then
    myUserObj = sprite(getaProp(gpObjects, gMyName)).scriptInstanceList[1]
    if myUserObj.controller = 1 then
      sendSprite(getaProp(gpUiButtons, "movestuff"), #disable)
      sendSprite(getaProp(gpUiButtons, "rotatestuff"), #disable)
      sendSprite(getaProp(gpUiButtons, "pickstuff"), #enable)
      sendSprite(getaProp(gpUiButtons, "removestuff"), #disable)
    end if
  end if
end
