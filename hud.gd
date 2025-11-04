extends CanvasLayer

@onready var time_label = $ClockPanel/TimeLabel
@onready var day_label = $ClockPanel/DayLabel

func _on_time_changed(hours: int, minutes: int):
	time_label.text = "%02d:%02d" % [hours, minutes]

func _on_day_changed(current_season: String, current_day: int):
	day_label.text = "%s %s" % [current_season, current_day]
