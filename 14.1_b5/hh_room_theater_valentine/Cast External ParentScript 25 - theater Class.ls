property pAnimPhase, pAnimTimer

on construct me
  pAnimPhase = 0
  pAnimTimer = the timer
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on update me
  case pAnimPhase of
    0:
      if the timer > (pAnimTimer + (60 * 20)) then
        if random(20) = 1 then
          tMode = random(4)
          tObj = getThread(#room).getInterface().getRoomVisualizer()
          if tObj = 0 then
            return 0
          end if
          case tMode of
            1:
              tSp = tObj.getSprById("valentinebear_eyes")
              if tSp = 0 then
                return 0
              end if
              tSp.blend = 100
              pAnimPhase = 3
            2:
              tSp = tObj.getSprById("valentinebear_ears")
              if tSp = 0 then
                return 0
              end if
              tSp.blend = 100
              pAnimPhase = 3
            3:
              tSp1 = tObj.getSprById("valentinebear_ears")
              tSp2 = tObj.getSprById("valentinebear_eyes")
              if (tSp1 = 0) or (tSp2 = 0) then
                return 0
              end if
              tSp1.blend = 100
              tSp2.blend = 100
              pAnimPhase = 3
            4:
              tSp = tObj.getSprById("valentinebear_eyes")
              if tSp = 0 then
                return 0
              end if
              tSp.blend = 100
              pAnimPhase = 1
          end case
          pAnimTimer = the timer
        end if
      end if
    1:
      if the timer > (pAnimTimer + 10) then
        tObj = getThread(#room).getInterface().getRoomVisualizer()
        if tObj = 0 then
          return 0
        end if
        tSp1 = tObj.getSprById("valentinebear_eyes")
        if tSp1 = 0 then
          return 0
        end if
        tSp1.blend = 0
        pAnimPhase = 2
      end if
    2:
      if the timer > (pAnimTimer + 20) then
        tObj = getThread(#room).getInterface().getRoomVisualizer()
        if tObj = 0 then
          return 0
        end if
        tSp1 = tObj.getSprById("valentinebear_eyes")
        if tSp1 = 0 then
          return 0
        end if
        tSp1.blend = 100
        pAnimPhase = 3
      end if
    3:
      if the timer > (pAnimTimer + 30) then
        tObj = getThread(#room).getInterface().getRoomVisualizer()
        if tObj = 0 then
          return 0
        end if
        tSp1 = tObj.getSprById("valentinebear_ears")
        tSp2 = tObj.getSprById("valentinebear_eyes")
        if (tSp1 = 0) or (tSp2 = 0) then
          return 0
        end if
        tSp1.blend = 0
        tSp2.blend = 0
        pAnimPhase = 0
        pAnimTimer = the timer
      end if
  end case
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tPar = tMsg[#show_params]
  put tDst, tCmd, tPar
end
