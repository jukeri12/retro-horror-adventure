extends StaticBody

onready var globals = get_node("/root/Global")

# AdventureEntry.gd - Interact with to enter a text adventure section
export var adventure_file = "test"

func run_text_adventure(adventure_filename: String):
	# Set TextAdventure module to load Text Adventure file and start it.
	var text_adventure_module = get_node(globals.TEXT_ADVENTURE_MODULE)
	text_adventure_module.story_file = adventure_filename
	text_adventure_module.run_story()
	
	# Call Game Controller to set text adventure mode
	var game_controller = get_node(globals.GAME_MODULE)
	game_controller.swap_to_text_adventure()

func _on_AdventureEntry_input_event(camera, event, click_position, click_normal, shape_idx):
	# On clicking it, run the adventure that is connected to this
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		print("Starting text adventure %s..." % adventure_file)
		run_text_adventure(adventure_file)
