on construct(me)
  pTicketCount = "?"
  return(1)
  exit
end

on getTicketCount(me)
  return(pTicketCount)
  exit
end

on setTicketCount(me, tCount)
  pTicketCount = tCount
  exit
end