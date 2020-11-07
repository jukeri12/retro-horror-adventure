extends KinematicBody

const SPEED = 0.05

onready var eyes = get_node("Eyes")

# Player is a crook (swedish thief?)

# Player statistics
var character_name = "Iuga"
var strength = 1
var dexterity = 1
var speech = 3

# Can take a maximum of 5 hits
var max_health = 5
var health = 5  

# OTher stats
var text_adventure_mode = false

 # List of item strings: items have context-dependent purposes
var inventory = ["cigarettes"]

func _ready():
	# Set camera upon initial appearance
	eyes.current = true

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
