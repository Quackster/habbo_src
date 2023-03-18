global gPlastoCodeColor, gPlastoCodeModel, gPlastoCodeSpr, gPlastoSpr, gPlastoColor, gCatalogPopUp

on beginSprite me
  gPlastoCodeSpr = me.spriteNum
  initPlasto()
end

on updateCode me
  if voidp(gPlastoCodeColor) then
    gPlastoCodeColor = "H"
  end if
  if voidp(gPlastoCodeModel) then
    gPlastoCodeModel = "E"
  end if
  member("PlastoCodeField").text = "A1 " & gPlastoCodeModel & gPlastoCodeColor & "P"
end

on initPlasto me
  if objectp(gCatalogPopUp) then
    if gCatalogPopUp.frame = "plas" then
      gPlastoCodeModel = "E"
      gPlastoCodeColor = "H"
      gPlastoColor = "255,255,255"
      sendSprite(gPlastoSpr, #updateColor)
      sendSprite(gPlastoSpr + 2, #updateColor)
      member("PlastoCodeField").text = "A1 " & gPlastoCodeModel & gPlastoCodeColor & "P"
    end if
  end if
end
