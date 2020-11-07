extends Node2D


var game_on = false
var text_adventure_section = false

# Load globals
onready var globals = get_node("/root/Global")

# TODO: Load multiple game maps
onready var game_scene = preload("res://Assets/Boat.tscn")

onready var player_ui_scene = preload("res://Assets/PlayerUI.tscn")
onready var player_scene = preload("res://Assets/Player.tscn")
onready var text_adventure_scene = preload("res://Assets/TextAdventure.tscn")
onready var main_menu_scene = preload("res://Assets/MainMenu.tscn")

onready var jukebox = get_node("Music")

# Game.gd - main game controller
# Switches on/off menu, in-game and shows text adventure UI
# Also a kind of simple handler for global stats (like player stats and triggers)

func start_game():
	# Initial setup
	var player_ui_instance = player_ui_scene.instance()
	add_child(player_ui_instance)

	# Text adventure module setup
	var text_adventure_scene_instance = text_adventure_scene.instance()
	add_child(text_adventure_scene_instance)
	text_adventure_scene_instance.visible = false

	# Setup first game map
	var game_scene_instance = game_scene.instance()
	game_scene_instance.name = "Level"
	add_child(game_scene_instance)
	var player_instance = player_scene.instance()
	game_scene_instance.add_child(player_instance)
	var spawn = game_scene_instance.get_node("Spawn")
	player_instance.transform = spawn.transform
	
	var main_menu_instance = get_node("MainMenu")
	# TODO: if everything else is controlled with "visibility", is this consistent?
	main_menu_instance.visible = false
	game_on = true

func _ready():
	# TODO: Link signals
	var main_menu_instance = main_menu_scene.instance()
	var start_game_btn = main_menu_instance.get_node("VBoxContainer/StartGame")
	start_game_btn.connect("button_down", self, "start_game")
	add_child(main_menu_instance)
	
# Game scene change controls and stuff in a central location
func swap_to_text_adventure():
	# Switch to text adventure mode: Disable exploration mode controls
	# and show text adventure display
	if game_on:
		var player_node = get_node(globals.PLAYER_OBJECT_MODULE)
		player_node.text_adventure_mode = true
		var text_adventure_module = get_node(globals.TEXT_ADVENTURE_MODULE)
		text_adventure_module.visible = true
		print("TEXT ADVENTURE MODE")
	else:
		print("WARNING: Attempted to switch modes while game is not started!")
		
func swap_to_exploration():
	# Switch to exploration: Clean text adventure module, disable it's display
	# and return controls to player
	if game_on:
		var player_node = get_node(globals.PLAYER_OBJECT_MODULE)
		player_node.text_adventure_mode = false
		var text_adventure_module = get_node(globals.TEXT_ADVENTURE_MODULE)
		text_adventure_module.visible = false
		print("EXPLORATION MODE")
	else:
		print("WARNING: Attempted to switch modes while game is not started!")
