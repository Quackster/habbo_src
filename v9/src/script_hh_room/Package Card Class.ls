property pMessage, pPackageID, pCardWndID

on construct me
  pMessage = EMPTY
  pPackageID = EMPTY
  pCardWndID = ("Card" && getUniqueID())
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  return 1
end

on deconstruct me
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on define me, tProps
  pPackageID = tProps[#id]
  pMessage = tProps[#Msg]
  me.showCard((tProps[#loc] + [0, -220]))
  return 1
end

on showCard me, tloc
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if (tloc[1] > (the stage.rect.width - 260)) then
    tloc[1] = (the stage.rect.width - 260)
  end if
  if (tloc[2] < 2) then
    tloc[2] = 2
  end if
  if not createWindow(pCardWndID, "package_card.window", tloc[1], tloc[2]) then
    return 0
  end if
  tWndObj = getWindow(pCardWndID)
  tUserRights = getObject(#session).get("user_rights")
  tUserCanOpen = (getObject(#session).get("room_owner") or tUserRights.findPos("fuse_pick_up_any_furni"))
  if (not tUserCanOpen and (tWndObj.getElement("open_package") <> 0)) then
    tWndObj.getElement("open_package").Hide()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  tWndObj.getElement("package_msg").setText(pMessage)
  return 1
end

on hideCard me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return 1
end

on openPresent me
  return getThread(#room).getComponent().getRoomConnection().send("PRESENTOPEN", pPackageID)
end

on showContent me, tdata
  if not windowExists(pCardWndID) then
    return 0
  end if
  ttype = tdata[#type]
  tCode = tdata[#code]
  tMemNum = VOID
  if (ttype contains "*") then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    ttype = ttype.item[1]
    the itemDelimiter = tDelim
  end if
  if memberExists((tCode & "_small")) then
    tMemNum = getmemnum((tCode & "_small"))
  else
    if memberExists(("ctlg_pic_small_" & tCode)) then
      tMemNum = getmemnum(("ctlg_pic_small_" & tCode))
    end if
  end if
  if (tMemNum = 0) then
    tImg = getObject("Preview_renderer").renderPreviewImage(VOID, VOID, VOID, tdata[#type])
  else
    tImg = member(tMemNum).image.duplicate()
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.getElement("card_icon").Hide()
  tWndObj.getElement("small_img").feedImage(tImg)
  tWndObj.getElement("small_img").setProperty(#blend, 100)
  tWndObj.getElement("open_package").Hide()
end

on eventProcCard me, tEvent, tElemID, tParam
  if (tEvent <> #mouseUp) then
    return 0
  end if
  case tElemID of
    "close":
      return me.hideCard()
    "open_package":
      return me.openPresent()
  end case
end
