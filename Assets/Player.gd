extends KinematicBody

const SPEED = 0.05

onready var eyes = get_node("Eyes")
onready var globals = get_node("/root/Global")

# Player is a crook (swedish thief?)

# Player statistics
var character_name = "Iuga"
var strength = 1
var dexterity = 1
var speech = 3

# Can take a maximum of 5 hits
var max_health = 5
var health = 1  

# OTher stats
var text_adventure_mode = false

 # List of item strings: items have context-dependent purposes
var inventory = ["cigarettes"]

func _ready():
	# Set camera upon initial appearance
	eyes.current = true

func set_stat(stat_to_set, new_value):
	# Check that stat is settable, enforce conditions and set it
	set(stat_to_set, new_value)
	
func perform_operation_on_stat(stat_to_set, operation, value):
	# Increase or decrease stat
	var old_stat_val = get(stat_to_set)
	# TODO: There probably is a smart way to get operation type
	var new_val = old_stat_val
	if operation == "+":
		new_val = old_stat_val + value
	elif operation == "-":
		new_val = old_stat_val - value
	
	set(stat_to_set, new_val)

func damage(amount):
	# Play a hit effect and do damage for x amount
	# Check if death occurs
	# TODO: Visuals and sound
	health = health - 1
	if health < 1:
		death()

func death():
	# Flare UI game over, remove all control from user
	# except for returning user to menu
	var ui = get_node(globals.PLAYER_UI_MODULE)
	ui.display_game_over()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# TODO: Add cinematic mouse "follow" effects
	if text_adventure_mode == false:
		if Input.is_action_pressed("move_forward"):
			# TODO: Speed calculation for sprint
			
			var facing = global_transform.basis.z
			facing = facing * (SPEED * 4)
			move_and_collide(-facing)
	
		if Input.is_action_pressed("move_backward"):
			var facing = global_transform.basis.z
			facing = facing * (SPEED * 4)
			move_and_collide(facing)
			
		if Input.is_action_pressed("move_left"):
			move_and_collide(Vector3(-SPEED, 0, 0))
			
		if Input.is_action_pressed("move_right"):
			move_and_collide(Vector3(SPEED, 0, 0))
	
		if Input.is_action_pressed("turn_left"):
			rotate(Vector3(0, 1, 0), SPEED)
			
		if Input.is_action_pressed("turn_right"):
			rotate(Vector3(0, 1, 0), -SPEED)
