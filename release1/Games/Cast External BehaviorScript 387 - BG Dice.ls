property dicenum, n, used
global gBgDices, gBackgammon

on beginSprite me
  if voidp(gBgDices) then
    gBgDices = [0, 0]
  end if
  gBgDices[dicenum] = me.spriteNum
end

on set me, tn
  n = tn
  used = 0
  sprite(me.spriteNum).member = getmemnum("dice" & n)
end

on getPropertyDescriptionList me
  return [#dicenum: [#comment: "Dice num", #default: 0, #format: #integer]]
end

on mouseDown me
  global gBGChosenPiece
  if objectp(gBGChosenPiece) and not used then
    sendItemMessage(gBackgammon, "MOVE" && gBGChosenPiece.slot - 1 && dicenum - 1)
  else
    beep(1)
  end if
end

on setUsed me, b
  used = b
  if b then
    sprite(me.spriteNum).member = getmemnum("dice" & n && "used")
  else
    sprite(me.spriteNum).member = getmemnum("dice" & n)
  end if
end
