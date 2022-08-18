global G_IntVectorScript

on initIntVector
  G_IntVectorScript = script("CIntVector")
end

on intvector a_iX, a_iY, a_iZ
  return G_IntVectorScript.new(a_iX, a_iY, a_iZ)
end
