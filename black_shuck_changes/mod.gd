extends ContentInfo

var black_shuck_quest_weight: float = 1.0 # Double the default weight of 0.5
var black_shuck_quest_map_icon: bool = true

func init_content():
	var modutils: ContentInfo = DLC.mods_by_id["cat_modutils"]

	mod_print("Loading Black Shuck changes mod...")

	# Change the chance of Black Shuck spawning
	set_black_shuck_quest_weight(black_shuck_quest_weight)

	# Setup a callback to add a map icon to the Black Shuck's location
	DLC.mods_by_id.cat_modutils.callbacks.connect_scene_ready(
		"res://data/passive_quests/BlackShuckQuest.tscn",
		self,
		"_on_BlackShuckQuest_ready"
	)

	mod_print("Finished loading Black Shuck changes mod.")

func set_black_shuck_quest_weight(weight: float):
	var black_shuck = load("res://data/passive_quests/black_shuck.tres")
	mod_print("Previous black shuck quest weight: %s" % black_shuck.weight)
	black_shuck.weight = weight # This is the line that actually does the work

	# Double check some values for debugging purposes
	mod_print("New black shuck quest weight: %s" % black_shuck.weight)

	var black_shuck2 = load("res://data/passive_quests/black_shuck.tres")
	mod_print("Double checking black shuck quest weight: %s" % black_shuck2.weight)

	mod_print("Checking weights in passive quest system.")
	var quest_metas = Datatables.load("res://data/passive_quests").table.values()
	quest_metas = PassiveQuestSystem.quest_metas
	for quest in quest_metas:
		mod_print(quest.weight)

func _on_BlackShuckQuest_ready(scene: Node) -> void:
	mod_print("There's a Black Shuck quest.")

	if black_shuck_quest_map_icon:
		mod_print("Enabling Black Shuck map icon for this quest")
		var black_shuck_quest = scene

		mod_print("%s" % black_shuck_quest)
		mod_print("%s" % black_shuck_quest.map_marker_icons)

		# Set the quest title and map icon. Note that setting the title is required for the map
		# icon to be displayed
		black_shuck_quest.title = "PASSIVE_QUEST_UNKNOWN_TITLE"
		black_shuck_quest.map_marker_icons = [
			load("res://mods/black_shuck_changes/black_shuck.png")
		]

		mod_print("%s" % black_shuck_quest.map_marker_icons)

func mod_print(string: String):
	Console.writeLine("black_shuck_changes > %s" % string)
