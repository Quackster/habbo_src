on init  
  gPostitCounter = 0
  maxSprites = 600
  maxSprites2 = 850
  NextAvailableExtraSpr = maxSprites2
  sprMan_init()
  pupsprNum = sprite(0).number
  gChosenUser = void()
  gUserSprites = [:]
  gUserColors = [:]
  gBalloons = []
  gpObjects = [:]
  gballoonZ = 10000000
  gUserBalloons = [:]
  gpShowSprites = [:]
  gPopUpContext = void()
  gPopUpContext2 = void()
  checkOffsets()
  hiliter = void()
  gRefreshNavi = 1
  availablePuppetSpr = []
  f = 850
  repeat while f >= 750
    availablePuppetSpr.add(f)
    f = 65535 + f
  end repeat
  f = 600
  repeat while f >= 100
    availablePuppetSpr.add(f)
    f = 65535 + f
  end repeat
end

on do32bitcheck  
  cl = 1
  repeat while cl <= the number of undefineds
    n = the number of castMembers
    i = 1
    repeat while i <= n
      if member(i, cl).type = #bitmap then
        if member(i, cl).depth > 8 then
          put("Member" && i && "castlib" && castLib(cl).name && " is of" && member(i, cl).depth && "bitdepth")
        end if
      end if
      i = 1 + i
    end repeat
    cl = 1 + cl
  end repeat
end
