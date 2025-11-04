extends Node

# Starting Calendar
var current_season = "Spring"
var current_day = 1

# Signal to update the HUD Calendar
signal update_hud_calendar(current_season: String, current_day: int)

# When a new day occurs Increment the day and update the HUD
func update_day():
	current_day += 1
	
	# If previous day was the 28th then Increment the day and update Season
	if current_day > 28:
		current_day = 1
		update_season()
	else:
		update_hud_calendar.emit(current_season, current_day)
		
# When a new season occurs Increment the season and update the HUD
func update_season():
	match current_season:
		"Spring":
			current_season = "Summer"
		"Summer":
			current_season = "Fall"
		"Fall":
			current_season = "Winter"
		"Winter":
			current_season = "Spring"
			
	update_hud_calendar.emit(current_season, current_day)
