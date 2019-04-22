on construct(me)
  m_ar_subturns = []
  m_iNumber = -1
  m_bTested = 0
  m_iChecksum = 0
  return(1)
  exit
end

on deconstruct(me)
  m_ar_subturns = []
  return(1)
  exit
end

on AddElement(me, i_iSubturn, i_rElement)
  if m_ar_subturns.count < i_iSubturn then
    i = m_ar_subturns.count + 1
    repeat while i <= i_iSubturn
      m_ar_subturns.append([])
      i = 1 + i
    end repeat
  end if
  if not voidp(i_rElement) then
    m_ar_subturns.getAt(i_iSubturn).append(i_rElement)
  end if
  exit
end

on setNumber(me, i_iNumber)
  m_iNumber = i_iNumber
  exit
end

on SetChecksum(me, i_iChecksum)
  m_iChecksum = i_iChecksum
  exit
end

on GetSubTurn(me, i_iSubturn)
  if i_iSubturn > m_ar_subturns.count or i_iSubturn < 1 then
    put("MGEngine : Requested subturn " & i_iSubturn & " that does not exist")
    return([])
  end if
  return(m_ar_subturns.getAt(i_iSubturn))
  exit
end

on GetNSubTurns(me)
  return(m_ar_subturns.count)
  exit
end

on GetNumber(me)
  return(m_iNumber)
  exit
end

on GetCheckSum(me)
  return(m_iChecksum)
  exit
end

on GetTested(me)
  return(m_bTested)
  exit
end

on SetTested(me, a_bVal)
  m_bTested = a_bVal
  exit
end

on GetSubTurns(me)
  return(m_ar_subturns)
  exit
end

on dump(me)
  put("* Turn dump:" && m_iNumber && "events:" && m_ar_subturns)
  exit
end