extends CharacterBody2D

# magic hammer of Yurglowmer

@export var speed = 75  # Movement speed

var last_direction = "down" # Direction faced when loading in
var current_tool = "hoe" # Starting tool TEMPORARY

# Signal for when an item in the inventory is used
signal use_item(current_tool: String, global_position: Vector2, last_direction: String)

# Setting onready variables allow us to designate space and reference before it's called
# Keeps us from "calling" the functions etc everytime
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.animation = "idle_down"
	animated_sprite.play()
	position = Vector2(5 * 32, 5 * 32)	# Player starting position

func _physics_process(_delta: float) -> void:
	
	# Calls function if player uses item in hand
	if Input.is_action_just_pressed("use_item"):
		use_item.emit(current_tool, global_position, last_direction)
		
	# Swaps to hotbar items
	if Input.is_action_just_pressed("hotbar_1"):
		current_tool = "hoe"
	if Input.is_action_just_pressed("hotbar_2"):
		current_tool = "wheat"
	if Input.is_action_just_pressed("hotbar_3"):
		current_tool = "scythe"
	
	# Resets input direction to zero vector
	var input_direction = Vector2.ZERO
	
	# Determines key press and direction moved
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	
	# Normalize for consistent diagonal speed (player doesn't move faster on the diagonal)
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
	
	# Set velocity
	velocity = input_direction * speed
	
	# Move with collision detection
	move_and_slide()
	
	# Handle animations
	if velocity.x > 0:
		animated_sprite.animation = "walk_right"
		last_direction = "right"
	elif velocity.x < 0:
		animated_sprite.animation = "walk_left"
		last_direction = "left"
	elif velocity.y > 0:
		animated_sprite.animation = "walk_down"
		last_direction = "down"
	elif velocity.y < 0:
		animated_sprite.animation = "walk_up"
		last_direction = "up"
	else:
		animated_sprite.animation = "idle_" + last_direction
