extends Control


# Text Adventure sections
# Load specifically formatted files that contain texts, choices
# and effects. Decision trees should be simple, but effective
# e.g. no going back is _required_ to be implemented
# so if player clicks on something it means committing to that choice

# SAMPLE ADVENTURE
#{
#	initial: {
#		text: "Before you are three cups: one red, one yellow, one blue. Which will you pick?",
#		choices: [
#			{text: "Pick the red one.", response: "You pick the red one.", effects: ["gain_red"], destination: ""},
#			{text: "Pick the yellow one.", response: "You pick the yellow one.", effects: ["gain_yellow"], destination: ""},
#			{text: "Pick the blue one.", response: "You pick the blue one.", effects: ["gain_blue"], destination: ""},
#		]
#	},
#	drinking: {
#		text: "You consider drinking from the cup.",
#		choices: [
#			{text: "Drink from the cup.", response: "", effects: ["determine_drink"], destination: ""},
#			{text: "Don't drink from the cup.", response: "You decide not to.", effects: [], destination: ""}
#		]
#	}
#}
#
# Where
#
# each key in root dictionary is a part of adventure in chronological order
# E.g. if nothing else happens, the story progresses from top to bottom
#
# keywords:
# text - descriptive text of current adventure part. "You are in a cave"
# choices - list of dicts of possible choices, containing Choice elements.
# Choice - a preformatted dict that contains text, effects and optional next destination
#   * response: text for response after clicking this Choice (optional) (WIP)
#   * effects: list of strings referring to functions in Game controller. Alters game stats in some way
#   * destination - which story part to go to by name after this one (optional). Go to next if none specified.
# Visualization - what asset objects to show and where in the text adventure scene.
#   * 
#
# SKETCHING SOME THINGS
# Choices could have following keys:
# conditions - list of dicts of preformatted Conditions that are needed for this to be shown. Sampling:
#   * "has:X": has item with ID X. String ID.
#   * "X:is_Y": stat X is equal to Y. String.
#   * "X:is_not_Y": stat X is not equal to Y. String.
#   * "X:lt_Y": stat X is less than Y. String.
#   * "X:lte_Y": stat X is less than or equal to Y. String.
#   * "X:gt_Y": stat X is greater than Y. String.
#   * "X:gte_Y": stat X is greater than or equal to Y. String.
# effects - what happens when you click on it. a sampling of effects possible:
#   * "gain:X": gain item X. String ID.
#   * "set:X_Y": set X stat to Y (sample: set "knows_a_guy" to "1""). String.
#   * "damage:X": player gains X amount of damage. Integer.
#   * "exit": Exit the text adventure section and return to exploration.
#   * "filter_choice_X": WIP: Remove a Choice or Story point entirely from future instances of text adventure

# Load globals
onready var globals = get_node("/root/Global")

onready var bg = get_node("Background")
onready var choices_container = get_node("ChoiceContainer")
onready var desc = get_node("Description")

export var story_file = "test"  # which JSON file to refer to/load
var story_data = {}  # Actual story data in memory
var raw_story_data = ""  # Textual reference to story data
var story_point = ""
var response_mode = false  # If current description is a response (can only reply "Continue")

var persistent_changes = null  # Store whatever changes have happened so no "gaming" can happen
var done_once = false  # If this has been done once
var available = true  # If scene is available any more

# TODO: What philosophy should be adapted to handle multiple entering into adventure scenes?

func run_story():
	# Wrapper function that runs everything 
	# necessary to transfer into text adventure mode
	clean()
	load_story()
	
	# Load first Text Scene
	# TODO: Can't get dictionary like this
	var first_item = story_data.keys()[0]
	_set_story_point(first_item)

func load_story():
	# Load raw story data and parse into this
	var file = File.new()
	file.open("res://Stories/" + story_file + ".json", File.READ)
	var content = file.get_as_text()
	raw_story_data = content

	var parsed = JSON.parse(content)
	if parsed.error == OK:
		story_data = parsed.result
	else:
		print("ERROR: Text Adventure JSON malformed! %s" % parsed.error)
	file.close()

func _create_story_choices(choices_data):
	for i in range(0, len(choices_data)):
		var new_button = Button.new()
		var button_data = choices_data[i]
		new_button.text = button_data["text"]
		choices_container.add_child(new_button)
		
		# Connect button target to set story point
		new_button.connect("pressed", self, "_start_transition", [button_data])

		# TODO: Add relevant links to Game controller
	
func _set_visual_elements():
	# TODO: Populate visual elements into text adventure section
	pass
	
func _start_transition(button_data):
	# Respond and create transition UI to next part
	_response_and_effects(button_data)

	# Create a dummy Continue response
	for child in choices_container.get_children():
		child.queue_free()
		
	var continue_button = Button.new()
	continue_button.text = "Continue"
	choices_container.add_child(continue_button)
	
	# From current story point, find next story point data
	var story_data_keys = story_data.keys()
	var next_destination = null
	var last_story_point = false
	var last_index = len(story_data_keys) - 1  # Helper variable
	var idx = 0
	for key in story_data:
		if key == story_point:
			if idx + 1 <= len(story_data_keys) - 1:
				next_destination = story_data_keys[idx + 1]
			else:
				next_destination = story_data_keys[idx]
			break
		idx += 1
	
	if "destination" in button_data:
		next_destination = button_data["destination"]
	# Check if this is the last story point: Force exit.
	if idx == last_index:
		last_story_point = true
		
	# Bind next story data to Continue Button
	if not last_story_point:
		continue_button.connect("pressed", self, "_set_story_point", [next_destination])
	else:
		continue_button.connect("pressed", self, "exit_story")
	
func _set_story_point(new_story_point):
	# TODO: Set proper story point and load all necessary data.
	# Another partial cleanup!
	for child in choices_container.get_children():
		child.queue_free()
	
	story_point = new_story_point
	desc.text = story_data[story_point]["text"]
	_create_story_choices(story_data[story_point]["choices"])

func _response_and_effects(choice_data):
	# TODO: Generate effects upon reply.
	# TODO: Choice needs to be integer
	# TODO: This is somewhat in the wrong place in respect to "exit" signal
	desc.text = choice_data["response"]
	
	# If effects are defined, do something
	if "effects" in choice_data:
		var raw_effects_data = choice_data["effects"]
		print(raw_effects_data)
		for effect_text in raw_effects_data:
			if effect_text == "exit":
				# TODO: Quit text adventure section BEFORE final element
				pass
				#exit_story()
			# TODO: Add stat setting functionalities
			if "damage:" in effect_text:
				# "damage:X"
				# Damage by amount X
				var parts = effect_text.split(":")
				var player = get_node(globals.PLAYER_OBJECT_MODULE)
				player.damage(parts[1])
				print("damage happens!")
				continue
			if "set:" in effect_text:
				# "set:stat_X"
				# Set player stat to X
				var parts = effect_text.split(":")
				var attribs = parts.split("_")
				var attrib_to_set = attribs[0]
				var attrib_new_val = attribs[1]
				var player = get_node(globals.PLAYER_OBJECT_MODULE)
				player.set_stat(attrib_to_set, attrib_new_val)
				continue
			if "operation:" in effect_text:
				# "operation:stat_X_Y"
				# Perform arithmetic on stat, operator X, value Y
				var parts = effect_text.split(":")
				var attribs = null
			else:
				print("WARNING: Effect not recognized!")

func clean():
	# Remove choices and story data
	story_data = {}
	for child in choices_container.get_children():
		child.queue_free()

func exit_story():
	# Clean up and call Game controller to do relevant stuff
	# This should only do cleanup internally. Rest is relevant to game developed
	clean()
	var game_controller = get_node(globals.GAME_MODULE)
	game_controller.swap_to_exploration()
