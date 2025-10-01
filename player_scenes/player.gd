extends CharacterBody2D

# --- Configuration: Movement ---
@export var speed: float = 400.0
@export var dash_speed: float = 1200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

# --- Configuration: Combat ---
@export var attack_duration: float = 0.3 # How long the sword swing animation lasts
@export var attack_speed_multiplier: float = 0.50 # Multiplier for movement speed while attacking (0.25 means 25% of base speed)

# --- Internal Variables ---
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

var is_attacking: bool = false
var attack_timer: float = 0.0

# --- Process for Aiming (Visual Update) ---
func _process(delta):
	# Aiming: Always rotate the character to face the mouse cursor.
	# This ensures the sword (which should be a child of this node) is pointing correctly.
	if is_attacking:
		# Optionally lock rotation while attacking for specific animations
		look_at(get_global_mouse_position()) 
	else:
		look_at(get_global_mouse_position())
		
# --- Attack Function ---
func start_attack():
	"""Initiates the sword swing action."""
	if not is_attacking:
		is_attacking = true
		attack_timer = attack_duration
		# At this point, you would trigger the sword animation and collision box.
		print("Sword Attack Started!")

# --- Physics Process (Movement and Action Logic) ---
func _physics_process(delta):
	# Read movement input once per frame so all states can access it
	var input_vector = Input.get_vector("left", "right", "up", "down").normalized()
	# 1. Update Timers
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	if is_attacking:
		# --- ATTACKING STATE ---
		# Apply reduced movement while attacking
		# The player moves in the input direction at a fraction of the base speed
		velocity = input_vector * (speed * attack_speed_multiplier)
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			print("Sword Attack Finished.")
	elif dash_timer > 0.0:
		# --- DASHING STATE ---
		# Apply dash movement in the stored direction
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		# Check for dash end
		if dash_timer <= 0.0:
			velocity = Vector2.ZERO # Stop immediately after dash
	else:
		# --- NORMAL STATE ---
		# Check for Attack (Input action "attack" assumed to be mouse click)
		if Input.is_action_just_pressed("attack"):
			start_attack()
		# Check for Dash (Dash only allowed if not attacking and cooldown is ready)
		elif Input.is_action_just_pressed("roll") and cooldown_timer <= 0.0:
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

	# Execute movement for all states (even if velocity is 0)
	move_and_slide()
