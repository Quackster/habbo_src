on startMovie  
  gBalloonMembers = void()
end

on InitBalloons  
  BalloonNums = 16
  gBalloonMembers = []
  f = 1
  repeat while f <= BalloonNums
    add(gBalloonMembers, "balloon_" & f)
    f = (1 + f)
  end repeat
  put(gBalloonMembers)
end
