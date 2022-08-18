on exitFrame me 
  if gPellePlayer <> void() then
    gPellePlayer.PlayerLoop()
  end if
  go(the frame)
end
