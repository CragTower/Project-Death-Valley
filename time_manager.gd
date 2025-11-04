extends Node

var time_scale = 180.0  # 1 real second = 1 game minut
var game_minutes = 240.0  # Start at 6:00 AM
var last_displayed_minute = -1  # For display updates - only update UI when needed

signal time_changed(hours: int, minutes: int)
signal new_day()

func _process(delta: float) -> void:
	# Accumulate time CONTINUOUSLY (every frame)
	game_minutes += delta * time_scale
	
	# Wrap at 24 hours
	if game_minutes >= 1440:
		game_minutes = 0
		new_day.emit()
	
	# Calculate current time
	var hours = int(game_minutes / 60) % 24
	var minutes = int(game_minutes) % 60
	
	# Only print/update when minute changes
	if minutes != last_displayed_minute:
		time_changed.emit(hours, minutes)
		last_displayed_minute = minutes
