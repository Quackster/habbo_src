on construct(me)
  pMessage = ""
  pPackageID = ""
  pCardWndID = "Card" && getUniqueID()
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  return(1)
  exit
end

on deconstruct(me)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
  exit
end

on define(me, tProps)
  pPackageID = tProps.getAt(#id)
  pMessage = tProps.getAt(#msg)
  me.showCard(tProps.getAt(#loc) + [0, -220])
  return(1)
  exit
end

on showCard(me, tloc)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if the stage > rect.width - 260 then
    1.setAt(the stage, rect.width - 260)
  end if
  if tloc.getAt(2) < 2 then
    tloc.setAt(2, 2)
  end if
  if not createWindow(pCardWndID, "package_card.window", tloc.getAt(1), tloc.getAt(2)) then
    return(0)
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  tWndObj.getElement("package_msg").setText(pMessage)
  return(1)
  exit
end

on hideCard(me)
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return(1)
  exit
end

on openPresent(me)
  return(getThread(#room).getComponent().getRoomConnection().send(#room, "PRESENTOPEN /" & pPackageID))
  exit
end

on showContent(me, tdata)
  if not windowExists(pCardWndID) then
    return(0)
  end if
  ttype = tdata.getAt(#type)
  tCode = tdata.getAt(#code)
  tMemNum = void()
  if ttype starts "credits" then
    tmember = getmemnum("credits_icon")
  else
    if ttype starts "deal" then
      tDealID = ttype.getProp(#char, 6, length(ttype))
      tMemNum = getmemnum("deal_icon_" & tDealID)
      if tMemNum = 0 then
        if memberExists("poster" && tDealID & "_small") then
          tMemNum = getmemnum("poster" && tDealID & "_small")
        else
          tMemNum = getmemnum("poster_small")
        end if
      end if
    else
      if ttype starts "poster" then
        tMemNum = getmemnum("poster" && tCode.getProp(#word, tCode.count(#word)) & "_small")
      else
        if ttype = "null" then
          if memberExists(tCode.getProp(#word, 2) & "_small") then
            tMemNum = getmemnum(tCode.getProp(#word, 2) & "_small")
          end if
        else
          tTryDealName = "deal" && tCode.getProp(#word, 2) & "_small"
          if memberExists(tTryDealName) then
            tMemNum = getmemnum(tTryDealName)
          else
            if memberExists(ttype & "_small") then
              tMemNum = getmemnum(ttype & "_small")
            else
              if ttype contains "*" then
                a = offset("*", ttype)
                tMemNum = getmemnum(ttype.getProp(#char, 1, a - 1) & "_small")
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  if tMemNum = 0 then
    if memberExists("no_icon_small") then
      tImg = image.duplicate()
    else
      tImg = image(1, 1, 8)
    end if
  else
    tImg = image.duplicate()
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.getElement("card_icon").hide()
  tWndObj.getElement("small_img").feedImage(tImg)
  tWndObj.getElement("small_img").setProperty(#blend, 100)
  tWndObj.getElement("open_package").hide()
  exit
end

on eventProcCard(me, tEvent, tElemID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "close" then
    return(me.hideCard())
  else
    if me = "open_package" then
      return(me.openPresent())
    end if
  end if
  exit
end