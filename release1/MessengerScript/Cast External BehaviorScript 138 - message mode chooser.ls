property myMode, Active
global gMModeChosenSpr, gMModeChosenMode, gBuddyList

on beginSprite me
  if myMode = "MESSENGER" then
    enable(me)
  else
    disable(me)
  end if
  Active = 1
  if myMode = "SMS" then
    recps = field("receivers")
    repeat with i = 1 to the number of words in recps
      id = integer(word i of recps)
      p = getPropsById(gBuddyList, id)
      if p <> VOID then
        if p.smsOk = 0 then
          Active = 0
        end if
      end if
    end repeat
  end if
  activate(me, Active)
end

on enable me
  global gMessageFieldSpr
  if not voidp(gMModeChosenSpr) then
    sendSprite(gMModeChosenSpr, #disable)
  end if
  gMModeChosenSpr = me.spriteNum
  sprite(me.spriteNum).member = "radio_btn on"
  gMModeChosenMode = myMode
  if gMModeChosenMode = "SMS" then
    sendSprite(gMessageFieldSpr, #setLimit, 125)
  else
    sendSprite(gMessageFieldSpr, #setLimit, 255)
  end if
end

on activate me, b
  Active = b
  if Active = 0 then
    sprite(me.spriteNum).blend = 50
    sprite(me.spriteNum + 1).blend = 50
  else
    sprite(me.spriteNum).blend = 100
    sprite(me.spriteNum + 1).blend = 100
  end if
end

on disable me
  sprite(me.spriteNum).member = "radio_btn off"
end

on mouseDown me
  if Active then
    enable(me)
  end if
end

on getPropertyDescriptionList me
  return [#myMode: [#format: #string, #range: ["EMAIL", "MESSENGER", "SMS"], #default: "MESSENGER", #comment: "mode"]]
end
