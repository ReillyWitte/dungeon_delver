extends CharacterBody2D

# --- Configuration ---
@export var speed: float = 400.0
@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.4

# Internal variables
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	# Update Cooldown Timer
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	if dash_timer > 0.0:
		# --- DASHING STATE ---
		# Apply dash movement in the stored direction
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		# Check for dash end
		if dash_timer <= 0.0:
			velocity = Vector2.ZERO # Stop immediately after dash
	else:
		# --- NORMAL STATE ---
		var input_vector = Input.get_vector("left", "right", "up", "down").normalized()
		# Check for dash start
		if Input.is_action_just_pressed("roll") and cooldown_timer <= 0.0:
			# Start dash
			dash_timer = dash_duration
			cooldown_timer = dash_cooldown
			# Set dash direction: use input, or default to down if standing still
			dash_direction = input_vector if input_vector != Vector2.ZERO else Vector2.DOWN
			# Apply dash velocity immediately for this frame
			velocity = dash_direction * dash_speed
		else:
			# Apply normal movement
			velocity = input_vector * speed
	# Execute movement for both states
	move_and_slide()
