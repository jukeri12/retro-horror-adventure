extends Control

onready var globals = get_node("/root/Global")
onready var stats_container = get_node("Stats")
onready var inventory_container = get_node("Inventory")
onready var game_over = get_node("GameOverLabel")


func display_stats(stats):
	# Take a dictionary of stats and update them to Stats container
	# TODO: Get Keys
	for stat in stats:
		var new_label = Label.new()
		var new_stat_text = "%s: %s".format(stat[0], stat[1])
		new_label.text = new_stat_text
		print(stat)
		
		if not stats_container:
			stats_container = get_node("Stats")
		stats_container.add_child(new_label)

	
func display_inventory_items(items):
	# Add a text for each item in inventory
	# TODO: Later on images?
	for item in items:
		var new_label = Label.new()
		new_label.text = item
		
		if not inventory_container:
			inventory_container = get_node("Inventory")
		inventory_container.add_child(new_label)
	
func display_game_over():
	game_over.visible = true
	inventory_container.visible = false
