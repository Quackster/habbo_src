property parentSprite

on new me, tParentSprite
  parentSprite = tParentSprite
  return me
end

on beginSprite me
end

on mouseDown me
  sendSprite(parentSprite, #mouseDown)
end

on mouseUp me
  sendSprite(parentSprite, #mouseUp)
end

on mouseEnter me
  sendSprite(parentSprite, #mouseEnter)
end

on mouseLeave me
  sendSprite(parentSprite, #mouseLeave)
end
