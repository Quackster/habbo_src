property pTicketCount

on construct me
  pTicketCount = "?"
  return 1
end

on getTicketCount me
  return pTicketCount
end

on setTicketCount me, tCount
  pTicketCount = tCount
end
