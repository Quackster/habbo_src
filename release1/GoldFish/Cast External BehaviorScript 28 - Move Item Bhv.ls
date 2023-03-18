global gChosenStuffSprite, gChosenStuffType, hiliter

on mouseUp me
  if gChosenStuffSprite > 0 then
    type = sprite(gChosenStuffSprite).scriptInstanceList[1].objectType
    case type of
      "poster":
        nothing()
      otherwise:
        moveStuff(hiliter, gChosenStuffSprite)
    end case
  end if
end
