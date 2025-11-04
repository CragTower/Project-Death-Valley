extends Node

var current_season = "Spring"
var current_day = 1

signal update_hud_calendar(current_season: String, current_day: int)

func update_day():
	current_day += 1
	if current_day > 28:
		current_day = 1
		update_season()
	else:
		update_hud_calendar.emit(current_season, current_day)
		
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
