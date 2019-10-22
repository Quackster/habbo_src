on getLevelHighscore me 
  tScoreData = me.getProperty(#top_level_scores)
  if listp(tScoreData) then
    return(tScoreData)
  end if
  me.requestHallOfFame()
  return FALSE
end

on getLevelTeamHighscore me 
  tScoreData = me.getProperty(#level_team_scores)
  if listp(tScoreData) then
    return(tScoreData)
  end if
  me.requestHallOfFame()
  return FALSE
end

on requestHallOfFame me 
  if me.getProperty(#score_data_pending) then
    return FALSE
  end if
  me.setProperty(#score_data_pending, 1)
  tService = me.getOwnerIGComponent()
  if (tService = 0) then
    return FALSE
  end if
  return(tService.getHandler().send_GET_LEVEL_HALL_OF_FAME(me.getProperty(#id)))
end
