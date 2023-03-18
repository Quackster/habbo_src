on init
  global gballoonZ, gUserBalloons, gpObjects, gBalloons, gUserColors, gUserSprites, gChosenUser, maxSprites, maxSprites2, pupsprNum, gpShowSprites, gMyName, gPopUpContext, gPopUpContext2, availablePuppetSpr, NextAvailableExtraSpr, gPostitCounter, hiliter, gRefreshNavi
  gPostitCounter = 0
  maxSprites = 600
  maxSprites2 = 850
  NextAvailableExtraSpr = maxSprites2
  sprMan_init()
  pupsprNum = the number of member "PuppetSprite"
  gChosenUser = VOID
  gUserSprites = [:]
  gUserColors = [:]
  gBalloons = []
  gpObjects = [:]
  gballoonZ = 10000000
  gUserBalloons = [:]
  gpShowSprites = [:]
  gPopUpContext = VOID
  gPopUpContext2 = VOID
  checkOffsets()
  hiliter = VOID
  gRefreshNavi = 1
  availablePuppetSpr = []
  repeat with f = 850 down to 750
    availablePuppetSpr.add(f)
  end repeat
  repeat with f = 600 down to 100
    availablePuppetSpr.add(f)
  end repeat
end

on do32bitcheck
  repeat with cl = 1 to the number of castLibs
    n = the number of castMembers of castLib cl
    repeat with i = 1 to n
      if member(i, cl).type = #bitmap then
        if member(i, cl).depth > 8 then
          put "Member" && i && "castlib" && castLib(cl).name && " is of" && member(i, cl).depth && "bitdepth"
        end if
      end if
    end repeat
  end repeat
end
