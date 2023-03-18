property m_ar_subturns, m_iNumber, m_iChecksum, m_bTested

on construct me
  m_ar_subturns = []
  m_iNumber = -1
  m_bTested = 0
  m_iChecksum = 0
  return 1
end

on deconstruct me
  m_ar_subturns = []
  return 1
end

on AddElement me, i_iSubturn, i_rElement
  if m_ar_subturns.count < i_iSubturn then
    repeat with i = m_ar_subturns.count + 1 to i_iSubturn
      m_ar_subturns.append([])
    end repeat
  end if
  if not voidp(i_rElement) then
    m_ar_subturns[i_iSubturn].append(i_rElement)
  end if
end

on SetNumber me, i_iNumber
  m_iNumber = i_iNumber
end

on SetChecksum me, i_iChecksum
  m_iChecksum = i_iChecksum
end

on GetSubTurn me, i_iSubturn
  if (i_iSubturn > m_ar_subturns.count) or (i_iSubturn < 1) then
    put "MGEngine : Requested subturn " & i_iSubturn & " that does not exist"
    return []
  end if
  return m_ar_subturns[i_iSubturn]
end

on GetNSubTurns me
  return m_ar_subturns.count
end

on GetNumber me
  return m_iNumber
end

on GetCheckSum me
  return m_iChecksum
end

on GetTested me
  return m_bTested
end

on SetTested me, a_bVal
  m_bTested = a_bVal
end

on GetSubTurns me
  return m_ar_subturns
end

on dump me
  put "* Turn dump:" && m_iNumber && "events:" && m_ar_subturns
end
