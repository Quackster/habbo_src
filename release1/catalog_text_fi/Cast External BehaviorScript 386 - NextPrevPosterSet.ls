property pDirection, spriteNum

on beginSprite me
  if member("poster_indexList").text.line.count <= 10 then
    sprite(spriteNum).blend = 40
  end if
end

on mouseUp me
  if sprite(spriteNum).blend < 100 then
    return 
  end if
  if pDirection = #next then
    sendAllSprites(#nextPosterSet)
  else
    sendAllSprites(#prevPosterSet)
  end if
end

on getPropertyDescriptionList
  description = [:]
  addProp(description, #pDirection, [#default: #next, #format: #symbol, #comment: "This button shows next/prev poster set..."])
  return description
end
