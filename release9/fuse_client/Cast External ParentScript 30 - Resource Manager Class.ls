property pAllMemNumList, pDynMemNumList, pBmpMemNumList, pLegalDuplicates, pBin

on construct me
  pAllMemNumList = [:]
  pAllMemNumList.sort()
  pDynMemNumList = []
  pDynMemNumList.sort()
  pBmpMemNumList = []
  pBmpMemNumList.sort()
  pBin = getVariable("dynamic.bin.cast", "bin")
  pLegalDuplicates = []
  pLegalDuplicates.add(getVariable("thread.index.field"))
  pLegalDuplicates.add(getVariable("alias.index.field"))
  pLegalDuplicates.add(getVariable("texts.index.field"))
  pLegalDuplicates.add(getVariable("props.index.field"))
  if the runMode contains "Author" then
    me.emptyDynamicBin()
  end if
  return 1
end

on deconstruct me
  if the runMode contains "Author" then
    me.deleteDynamicMembers()
  end if
  pAllMemNumList = [:]
  return 1
end

on getProperty me, tPropID
  case tPropID of
    #memberCount:
      return pAllMemNumList.count()
    #dynMemCount:
      return pDynMemNumList.count()
    otherwise:
      return 0
  end case
end

on setProperty me, tPropID, tValue
  case tPropID of
    otherwise:
      return 0
  end case
end

on createMember me, tMemName, ttype
  if not voidp(pAllMemNumList[tMemName]) then
    error(me, "Member already exists:" && tMemName, #createMember)
    return me.getmemnum(tMemName)
  end if
  if (ttype = #bitmap) and (pBmpMemNumList.count > 0) then
    tmember = member(pBmpMemNumList[1])
    pBmpMemNumList.deleteAt(1)
  else
    tmember = new(ttype, castLib(pBin))
    if not ilk(tmember, #member) then
      return error(me, "Failed to create member:" && tMemName && ttype, #createMember)
    end if
  end if
  tmember.name = tMemName
  tMemNum = tmember.number
  pAllMemNumList[tMemName] = tMemNum
  pDynMemNumList.add(tMemNum)
  return tMemNum
end

on removeMember me, tMemName
  tMemNum = pAllMemNumList[tMemName]
  if pDynMemNumList.getPos(tMemNum) < 1 then
    return error(me, "Can't delete member:" && tMemName, #removeMember)
  end if
  tmember = member(tMemNum)
  if tmember.type = #bitmap then
    tmember.name = EMPTY
    pBmpMemNumList.add(tMemNum)
  else
    tmember.erase()
  end if
  pDynMemNumList.deleteOne(tMemNum)
  pAllMemNumList.deleteProp(tMemName)
  return 1
end

on getMember me, tMemName
  tMemNum = pAllMemNumList[tMemName]
  if voidp(tMemNum) then
    tMemNum = 0
  end if
  return member(tMemNum)
end

on updateMember me, tMemName
  if tMemName.ilk <> #string then
    return error(me, "Member's name required:" && tMemName, #updateMember)
  end if
  if not me.unregisterMember(tMemName) then
    return 0
  end if
  if not me.registerMember(tMemName) then
    return 0
  end if
  return 1
end

on registerMember me, tMemName, tMemberNum
  if voidp(tMemberNum) then
    tMemberNum = member(tMemName).number
  end if
  if tMemberNum < 1 then
    return 0
  end if
  pAllMemNumList[tMemName] = tMemberNum
  return tMemberNum
end

on unregisterMember me, tMemName
  if voidp(pAllMemNumList[tMemName]) then
    return 0
  end if
  pAllMemNumList.deleteProp(tMemName)
  return 1
end

on preIndexMembers me, tCastNum
  if integerp(tCastNum) then
    tFirstCast = tCastNum
    tLastCast = tCastNum
  else
    pAllMemNumList = [:]
    pAllMemNumList.sort()
    tFirstCast = 1
    tLastCast = the number of castLibs
  end if
  tNameAlertFlag = getIntVariable("duplicate.name.alert")
  repeat with tCastLib = tFirstCast to tLastCast
    tMemberCount = the number of castMembers of castLib tCastLib
    repeat with i = 1 to tMemberCount
      tmember = member(i, tCastLib)
      if length(tmember.name) > 0 then
        if tNameAlertFlag then
          if not voidp(pAllMemNumList[tmember.name]) then
            if pLegalDuplicates.getPos(tmember.name) = 0 then
              if pAllMemNumList[tmember.name] <> tmember.number then
                tMemA = member(pAllMemNumList[tmember.name])
                tMemB = tmember
                if (tMemA.name <> EMPTY) and (tMemB.name <> EMPTY) then
                  tLibA = castLib(tMemA.castLibNum).name
                  tLibB = castLib(tMemB.castLibNum).name
                  error(me, "Duplicate member names:" && tmember.name && "/" && tLibA && "/" && tLibB, #preIndexMembers)
                end if
              end if
            end if
          end if
        end if
        pAllMemNumList[tmember.name] = tmember.number
      end if
    end repeat
    tVarIndex = getVariable("props.index.field")
    if member(tVarIndex, tCastLib).number > 0 then
      getVariableManager().dump(member(tVarIndex, tCastLib).number)
    end if
    tAliasIndex = getVariable("alias.index.field")
    if member(tAliasIndex, tCastLib).number > 0 then
      tAliasList = field(tAliasIndex, tCastLib)
      tItemDeLim = the itemDelimiter
      the itemDelimiter = "="
      repeat with i = 1 to tAliasList.line.count
        tLine = tAliasList.line[i]
        if length(tLine) > 2 then
          tName = item 2 to the number of items in tLine of tLine
          if the last char in tName = "*" then
            tName = tName.char[1..length(tName) - 1]
            tNumber = pAllMemNumList[tName]
            if tNumber > 0 then
              tReplacingNum = -tNumber
            else
              tReplacingNum = tNumber
            end if
          else
            tNumber = pAllMemNumList[tName]
            tReplacingNum = tNumber
          end if
          if tNumber > 0 then
            tMemName = item 1 of tLine
            pAllMemNumList[tMemName] = tReplacingNum
          end if
        end if
      end repeat
      the itemDelimiter = tItemDeLim
    end if
    tClsIndex = getVariable("class.index.field")
    if member(tClsIndex, tCastLib).number > 0 then
      getObject(#classes).dump(member(tClsIndex, tCastLib).number)
    end if
  end repeat
  return 1
end

on unregisterMembers me, tCastNum
  if voidp(tCastNum) then
    return me.clearMemNumLists()
  end if
  tMemberCount = the number of castMembers of castLib tCastNum
  repeat with i = 1 to tMemberCount
    tmember = member(i, tCastNum)
    tTempNum = pAllMemNumList[tmember.name]
    if tTempNum <> VOID then
      if tTempNum = tmember.number then
        pAllMemNumList.deleteProp(tmember.name)
      end if
    end if
    if pDynMemNumList.getPos(tmember.name) > 0 then
      pDynMemNumList.deleteAt(pDynMemNumList.getPos(tmember.name))
    end if
  end repeat
  tAliasIndex = getVariable("alias.index.field")
  if member(tAliasIndex, tCastNum).number > 0 then
    tAliasList = field(tAliasIndex, tCastNum)
    repeat with i = 1 to the number of lines in tAliasList
      tLine = tAliasList.line[i]
      if length(tLine) > 2 then
        tName = item 2 to the number of items in tLine of tLine
        if the last char in tName = "*" then
          tName = tName.char[1..length(tName) - 1]
        end if
        if not voidp(pAllMemNumList[tName]) then
          tMemName = item 1 of tLine
          if not voidp(tMemName) then
            pAllMemNumList.deleteProp(tMemName)
          end if
        end if
      end if
    end repeat
  end if
  return 1
end

on replaceMember me, tExistingMemName, tReplacingMemName
  if voidp(pAllMemNumList[tReplacingMemName]) then
    return 0
  end if
  pAllMemNumList[tExistingMemName] = pAllMemNumList[tReplacingMemName]
  return 1
end

on exists me, tMemName
  return not voidp(pAllMemNumList[tMemName])
end

on getmemnum me, tMemName
  tMemNum = pAllMemNumList[tMemName]
  if voidp(tMemNum) then
    tMemNum = 0
  end if
  return tMemNum
end

on print me
  repeat with i = 1 to pAllMemNumList.count
    put pAllMemNumList.getPropAt(i) && "--" && pAllMemNumList[i]
  end repeat
  return 1
end

on clearMemNumLists me
  pAllMemNumList = [:]
  pAllMemNumList.sort()
  return 1
end

on emptyDynamicBin me
  tMemberAmount = the number of castMembers of castLib pBin
  repeat with i = 1 to tMemberAmount
    tmember = member(i, pBin)
    if tmember.type <> #empty then
      tmember.erase()
    end if
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return 1
end

on deleteDynamicMembers me
  repeat with tMemNum in pDynMemNumList
    member(tMemNum).erase()
  end repeat
  repeat with tMemNum in pBmpMemNumList
    member(tMemNum).erase()
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return 1
end
