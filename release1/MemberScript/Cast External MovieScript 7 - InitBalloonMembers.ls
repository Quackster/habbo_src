global gBalloonMembers

on startMovie
  gBalloonMembers = VOID
end

on InitBalloons
  BalloonNums = 16
  gBalloonMembers = []
  repeat with f = 1 to BalloonNums
    add(gBalloonMembers, "balloon_" & f)
  end repeat
  put gBalloonMembers
end
