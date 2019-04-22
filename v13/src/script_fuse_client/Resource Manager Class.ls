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
  return(1)
end

on deconstruct me 
  if the runMode contains "Author" then
    me.deleteDynamicMembers()
  end if
  pAllMemNumList = [:]
  return(1)
end

on getProperty me, tPropID 
  if tPropID = #memberCount then
    return(pAllMemNumList.count())
  else
    if tPropID = #dynMemCount then
      return(pDynMemNumList.count())
    else
      return(0)
    end if
  end if
end

on setProperty me, tPropID, tValue 
  return(0)
end

on createMember me, tMemName, ttype, tForcedDuplicate 
  if not voidp(pAllMemNumList.getAt(tMemName)) and not tForcedDuplicate then
    error(me, "Member already exists:" && tMemName, #createMember)
    return(me.getmemnum(tMemName))
  end if
  if ttype = #bitmap and pBmpMemNumList.count > 0 then
    tmember = member(pBmpMemNumList.getAt(1))
    pBmpMemNumList.deleteAt(1)
  else
    tmember = new(ttype, castLib(pBin))
    if not ilk(tmember, #member) then
      return(error(me, "Failed to create member:" && tMemName && ttype, #createMember))
    end if
  end if
  tmember.name = tMemName
  tMemNum = tmember.number
  pAllMemNumList.setAt(tMemName, tMemNum)
  if pDynMemNumList.getPos(tMemNum) = 0 then
    pDynMemNumList.add(tMemNum)
  end if
  return(tMemNum)
end

on removeMember me, tMemName 
  tMemNum = pAllMemNumList.getAt(tMemName)
  if pDynMemNumList.getPos(tMemNum) < 1 then
    return(error(me, "Can't delete member:" && tMemName, #removeMember))
  end if
  tmember = member(tMemNum)
  if tmember.type = #bitmap then
    tmember.name = ""
    pBmpMemNumList.add(tMemNum)
  else
    tmember.erase()
  end if
  pDynMemNumList.deleteOne(tMemNum)
  pAllMemNumList.deleteProp(tMemName)
  return(1)
end

on getMember me, tMemName 
  tMemNum = pAllMemNumList.getAt(tMemName)
  if voidp(tMemNum) then
    tMemNum = 0
  end if
  return(member(tMemNum))
end

on updateMember me, tMemName 
  if tMemName.ilk <> #string then
    return(error(me, "Member's name required:" && tMemName, #updateMember))
  end if
  if not me.unregisterMember(tMemName) then
    return(0)
  end if
  if not me.registerMember(tMemName) then
    return(0)
  end if
  return(1)
end

on registerMember me, tMemName, tMemberNum 
  if voidp(tMemberNum) then
    tMemberNum = member(tMemName).number
  end if
  if tMemberNum < 1 then
    return(0)
  end if
  pAllMemNumList.setAt(tMemName, tMemberNum)
  return(tMemberNum)
end

on unregisterMember me, tMemName 
  if voidp(pAllMemNumList.getAt(tMemName)) then
    return(0)
  end if
  pAllMemNumList.deleteProp(tMemName)
  return(1)
end

on preIndexMembers me, tCastNum 
  if integerp(tCastNum) then
    tFirstCast = tCastNum
    tLastCast = tCastNum
  else
    pAllMemNumList = [:]
    pAllMemNumList.sort()
    tFirstCast = 1
    tLastCast = the number of undefineds
  end if
  tNameAlertFlag = getIntVariable("duplicate.name.alert")
  tCastLib = tFirstCast
  repeat while tCastLib <= tLastCast
    tMemberCount = the number of castMembers
    i = 1
    repeat while i <= tMemberCount
      tmember = member(i, tCastLib)
      if length(tmember.name) > 0 then
        if tNameAlertFlag then
          if not voidp(pAllMemNumList.getAt(tmember.name)) then
            if pLegalDuplicates.getPos(tmember.name) = 0 then
              if pAllMemNumList.getAt(tmember.name) <> tmember.number then
                tMemA = member(pAllMemNumList.getAt(tmember.name))
                tMemB = tmember
                if tMemA.name <> "" and tMemB.name <> "" then
                  tLibA = castLib(tMemA.castLibNum).name
                  tLibB = castLib(tMemB.castLibNum).name
                  error(me, "Duplicate member names:" && tmember.name && "/" && tLibA && "/" && tLibB, #preIndexMembers)
                end if
              end if
            end if
          end if
        end if
        pAllMemNumList.setAt(tmember.name, tmember.number)
      end if
      i = 1 + i
    end repeat
    tVarIndex = getVariable("props.index.field")
    if member(tVarIndex, tCastLib).number > 0 then
      getVariableManager().dump(member(tVarIndex, tCastLib).number)
    end if
    tAliasIndex = getVariable("alias.index.field")
    if member(tAliasIndex, tCastLib).number > 0 then
      me.readAliasIndexesFromField(tAliasIndex, tCastLib)
    end if
    tClsIndex = getVariable("class.index.field")
    if member(tClsIndex, tCastLib).number > 0 then
      getObject(#classes).dump(member(tClsIndex, tCastLib).number)
    end if
    tCastLib = 1 + tCastLib
  end repeat
  return(1)
end

on readAliasIndexesFromField me, tAliasIndex, tCastlibNo 
  tAliasList = field(tCastlibNo)
  tItemDeLim = the itemDelimiter
  the itemDelimiter = "="
  i = 1
  repeat while i <= tAliasList.count(#line)
    tLine = tAliasList.getProp(#line, i)
    if length(tLine) > 2 then
      tName = tLine.item[2..the number of item in tLine]
      if the last char in tName = "*" then
        tName = tName.getProp(#char, 1, length(tName) - 1)
        tNumber = pAllMemNumList.getAt(tName)
        if tNumber > 0 then
          tReplacingNum = -tNumber
        else
          tReplacingNum = tNumber
        end if
      else
        tNumber = pAllMemNumList.getAt(tName)
        tReplacingNum = tNumber
      end if
      if tNumber > 0 then
        tMemName = tLine.item[1]
        pAllMemNumList.setAt(tMemName, tReplacingNum)
      end if
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tItemDeLim
end

on unregisterMembers me, tCastNum 
  if voidp(tCastNum) then
    return(me.clearMemNumLists())
  end if
  tMemberCount = the number of castMembers
  i = 1
  repeat while i <= tMemberCount
    tmember = member(i, tCastNum)
    tTempNum = pAllMemNumList.getAt(tmember.name)
    if tTempNum <> void() then
      if tTempNum = tmember.number then
        pAllMemNumList.deleteProp(tmember.name)
      end if
    end if
    if pDynMemNumList.getPos(tmember.name) > 0 then
      pDynMemNumList.deleteAt(pDynMemNumList.getPos(tmember.name))
    end if
    i = 1 + i
  end repeat
  tAliasIndex = getVariable("alias.index.field")
  if member(tAliasIndex, tCastNum).number > 0 then
    tAliasList = field(tCastNum)
    i = 1
    repeat while i <= the number of line in tAliasList
      tLine = tAliasList.getProp(#line, i)
      if length(tLine) > 2 then
        tName = tLine.item[2..the number of item in tLine]
        if the last char in tName = "*" then
          tName = tName.getProp(#char, 1, length(tName) - 1)
        end if
        if not voidp(pAllMemNumList.getAt(tName)) then
          tMemName = tLine.item[1]
          if not voidp(tMemName) then
            pAllMemNumList.deleteProp(tMemName)
          end if
        end if
      end if
      i = 1 + i
    end repeat
  end if
  return(1)
end

on replaceMember me, tExistingMemName, tReplacingMemName 
  if voidp(pAllMemNumList.getAt(tReplacingMemName)) then
    return(0)
  end if
  pAllMemNumList.setAt(tExistingMemName, pAllMemNumList.getAt(tReplacingMemName))
  return(1)
end

on exists me, tMemName 
  return(not voidp(pAllMemNumList.getAt(tMemName)))
end

on getmemnum me, tMemName 
  tMemNum = pAllMemNumList.getAt(tMemName)
  if voidp(tMemNum) then
    tMemNum = 0
  end if
  return(tMemNum)
end

on print me 
  i = 1
  repeat while i <= pAllMemNumList.count
    put(pAllMemNumList.getPropAt(i) && "--" && pAllMemNumList.getAt(i))
    i = 1 + i
  end repeat
  return(1)
end

on clearMemNumLists me 
  pAllMemNumList = [:]
  pAllMemNumList.sort()
  return(1)
end

on emptyDynamicBin me 
  tMemberAmount = the number of castMembers
  i = 1
  repeat while i <= tMemberAmount
    tmember = member(i, pBin)
    if tmember.type <> #empty then
      tmember.erase()
    end if
    i = 1 + i
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return(1)
end

on deleteDynamicMembers me 
  repeat while pDynMemNumList <= undefined
    tMemNum = getAt(undefined, undefined)
    member(tMemNum).erase()
  end repeat
  repeat while pDynMemNumList <= undefined
    tMemNum = getAt(undefined, undefined)
    member(tMemNum).erase()
  end repeat
  pDynMemNumList = []
  pBmpMemNumList = []
  return(1)
end
