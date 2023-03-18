on exitFrame me
  global gPellePlayer
  if gPellePlayer <> VOID then
    gPellePlayer.PlayerLoop()
  end if
  go(the frame)
end
