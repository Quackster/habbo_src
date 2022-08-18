property spriteNum, pBuffer, pAmount, pStartPos, pParticles

on beginSprite me
  pBuffer = sprite(spriteNum).member.image
  pAmount = 20
  pStartPos = point((pBuffer.width / 2), (pBuffer.height - (pBuffer.height / 8)))
  repeat with i = 1 to pAmount
    pParticles.append(new(script("Particle"), me, pStartPos, 1.0, [1, 1, 1]))
  end repeat
end
