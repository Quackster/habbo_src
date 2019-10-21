property pTicketCount

on construct me 
  pTicketCount = "?"
  return TRUE
end

on getTicketCount me 
  return(pTicketCount)
end

on setTicketCount me, tCount 
  pTicketCount = tCount
end
