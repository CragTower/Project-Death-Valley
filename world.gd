extends Node2D

const DIRT_ATLAS_COORDS = Vector2i(6, 6)
const TILLED_SOIL_ATLAS_COORDS = Vector2i(6, 16)
const TEMP_SEED_IMAGE = Vector2i(0, 0)
const TEMP_ADOLESCENT_PLANT = Vector2i(0, 16)
const TEMP_MATURE_PLANT = Vector2i(0, 15)
const TILE_SET_SOURCE_ID = 10

var crops = {}
var crops_collected = {}
var day_color = Color(1.0, 1.0, 1.0)
var night_color = Color(0.3, 0.3, 0.5)

@onready var tile_map_layer = $TileMapLayer
@onready var tile_size = tile_map_layer.tile_set.tile_size.x # Finds the pixel size of tiles
@onready var daylight_change = $CanvasModulate


func _ready() -> void:
	$Calendar.update_hud_calendar.connect($HUD._on_day_changed)
	
	$Player.use_item.connect(_on_player_use_item)
	
	$TimeManager.time_changed.connect(_on_daylight_change)
	$TimeManager.time_changed.connect($HUD._on_time_changed)  # Fix after working
	$TimeManager.new_day.connect($Calendar.update_day)
	$TimeManager.new_day.connect(_on_day_changed_grow_crops)
	
	$HUD._on_day_changed($Calendar.current_season, $Calendar.current_day)

func _on_player_use_item(item_used: String, player_position: Vector2, player_direction: String):
	if item_used == "hoe":
		try_till_soil(player_position, player_direction)
	elif item_used == "wheat":
		try_plant_seed(item_used, player_position, player_direction)
	elif item_used == "scythe":
		try_harvest_crop(player_position, player_direction)
		
# Changes dirt to tilled soil
func try_till_soil(player_position: Vector2, player_direction: String):
	var target_coords = get_player_target_coords(player_position, player_direction)
	# Converts and sets Atlas coords for a one time call
	var current_tile = tile_map_layer.get_cell_atlas_coords(target_coords)
	
	# Toggles between untilled soil and tilled soil
	if current_tile == DIRT_ATLAS_COORDS:
		tile_map_layer.set_cell(target_coords, TILE_SET_SOURCE_ID, TILLED_SOIL_ATLAS_COORDS)
	elif current_tile == TILLED_SOIL_ATLAS_COORDS:
		tile_map_layer.set_cell(target_coords, TILE_SET_SOURCE_ID, DIRT_ATLAS_COORDS)
		
func try_plant_seed(current_tool: String, player_position: Vector2, player_direction: String):
	var target_coords = get_player_target_coords(player_position, player_direction)
	# Converts and sets Atlas coords for a one time call
	var current_tile = tile_map_layer.get_cell_atlas_coords(target_coords)
	
	if current_tile == TILLED_SOIL_ATLAS_COORDS and !crops.has(target_coords):
		tile_map_layer.set_cell(target_coords, TILE_SET_SOURCE_ID, TEMP_SEED_IMAGE)
		crops[target_coords] = {
			"type" = current_tool,
			"days_planted" = 0,
			"mature" = false
			}
			
func try_harvest_crop(player_position: Vector2, player_direction: String):
	var target_coords = get_player_target_coords(player_position, player_direction)
	
	if crops.has(target_coords) and crops[target_coords]["mature"] == true:
		tile_map_layer.set_cell(target_coords, TILE_SET_SOURCE_ID, TILLED_SOIL_ATLAS_COORDS)
		if !crops_collected.has(crops[target_coords]["type"]):
			crops_collected[crops[target_coords]["type"]] = {
				"count" = 1
			}
		else:
			crops_collected[crops[target_coords]["type"]]["count"] += 1
		
		crops.erase(target_coords)
	
func get_player_target_coords(player_position: Vector2, player_direction: String):
	# Sets target position to 1 tile in front of player
	var target_position = player_position
	if player_direction == "right":
		target_position.x += tile_size
	elif player_direction == "left":
		target_position.x -= tile_size 
	elif player_direction == "down":
		target_position.y += tile_size
	elif player_direction == "up":
		target_position.y -= tile_size
		
	# Sets the target's global position relative to the TileMapLayer (still in pixel coords)
	var local_target = tile_map_layer.to_local(target_position)
	# Converts pixel coords to TileMapLayer coords
	var target_coords = tile_map_layer.local_to_map(local_target)
	
	return target_coords
	
func _on_daylight_change(hours: int, minutes: int):
	var total_minutes = (hours * 60) + minutes
	var blend_factor = 0.0
	
	var sunrise_start = 4 * 60
	var sunrise_end = 6 * 60
	var sunset_start = 16 * 60
	var sunset_end = 18 * 60
	
	if total_minutes >= sunrise_start and total_minutes < sunrise_end:
		var sunrise_progress = float(total_minutes - sunrise_start) / float(sunrise_end - sunrise_start) 
		blend_factor = 1.0 - sunrise_progress
	elif total_minutes >= sunrise_end and total_minutes < sunset_start:
		blend_factor = 0.0
	elif total_minutes >= sunset_start and total_minutes < sunset_end:
		var sunset_progress = float(total_minutes - sunset_start) / float(sunset_end - sunset_start)
		blend_factor = 0.0 + sunset_progress
	else:
		blend_factor = 1.0
		
	daylight_change.color = day_color.lerp(night_color, blend_factor)
	
func _on_day_changed_grow_crops():
	for tile_coords in crops:
		crops[tile_coords]["days_planted"] += 1
		
		if crops[tile_coords]["days_planted"] == 3:
			tile_map_layer.set_cell(tile_coords, TILE_SET_SOURCE_ID, TEMP_MATURE_PLANT)
			crops[tile_coords]["mature"] = true
