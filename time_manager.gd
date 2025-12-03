extends Node

# Config for Timer
var time_scale = 200.0  # Speed of time (1.0 = 1 irl second or 1 in-game minute)
var game_minutes = 240.0  # Day Start time (360 = 6 AM)
var last_displayed_minute = -1  # For display updates - only update UI when needed

# Signals for when time changes and when a new day occurs (Midnight)
signal time_changed(hours: int, minutes: int)
signal new_day()

func _process(delta: float) -> void:
	# Accumulate time CONTINUOUSLY (every frame)
	game_minutes += delta * time_scale
	
	# Wrap at 24 hours and signal a new day has occurred
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
