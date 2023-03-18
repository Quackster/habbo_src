property playerNum, cardNum, selected
global gPoker

on beginSprite me
  select(me, 0)
  registerOtherCard(gPoker, me)
end

on setCard me, card
  sprite(me.spriteNum).castNum = getmemnum(card)
  sprite(me.spriteNum).width = member(getmemnum(card)).width
  sprite(me.spriteNum).height = member(getmemnum(card)).height
end

on select me, s
  selected = s
  put "small_back_" & selected
  sprite(me.spriteNum).castNum = getmemnum("small_back_" & selected)
  sprite(me.spriteNum).width = member(getmemnum("small_back_" & selected)).width
  sprite(me.spriteNum).height = member(getmemnum("small_back_" & selected)).height
end

on getPropertyDescriptionList me
  p = [:]
  addProp(p, #playerNum, [#comment: "Player num (1-3)", #format: #integer, #default: 1])
  addProp(p, #cardNum, [#comment: "Card num (1-5)", #format: #integer, #default: 1])
  return p
end
