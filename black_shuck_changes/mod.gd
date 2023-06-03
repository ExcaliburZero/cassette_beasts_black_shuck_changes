extends ContentInfo

var black_schuck_quest_weight: float = 9999.0
var black_shuck_quest_map_icon: bool = true

func init_content():
	var modutils: ContentInfo = DLC.mods_by_id["cat_modutils"]

	mod_print("Loading Black Schuck changes mod...")

	# Change the chance of Black Schuck spawning
	set_black_schuck_quest_weight(black_schuck_quest_weight)

	# Setup a callback to add a map icon to the Black Schuck's location
	DLC.mods_by_id.cat_modutils.callbacks.connect_scene_ready(
		"res://data/passive_quests/BlackShuckQuest.tscn",
		self,
		"_on_BlackShuckQuest_ready"
	)

	mod_print("Finished loading Black Schuck changes mod.")

func set_black_schuck_quest_weight(weight: float):
	var black_schuck = load("res://data/passive_quests/black_shuck.tres")
	mod_print("Previous black shuck quest weight: %s" % black_schuck.weight)
	black_schuck.weight = weight # This is the line that actually does the work

	# Double check some values for debugging purposes
	mod_print("New black shuck quest weight: %s" % black_schuck.weight)

	var black_schuck2 = load("res://data/passive_quests/black_shuck.tres")
	mod_print("Double checking black shuck quest weight: %s" % black_schuck2.weight)

	mod_print("Checking weights in passive quest system.");
	var quest_metas = Datatables.load("res://data/passive_quests").table.values()
	quest_metas = PassiveQuestSystem.quest_metas
	for quest in quest_metas:
		mod_print(quest.weight)

func _on_BlackShuckQuest_ready(scene: Node) -> void:
	mod_print("There's a Black Schuck quest.")

	if black_shuck_quest_map_icon:
		mod_print("Enabling Black Schuck map icon for this quest")
		var black_schuck_quest = scene

		mod_print("%s" % black_schuck_quest)
		mod_print("%s" % black_schuck_quest.map_marker_icons)

		# Set the quest title and map icon. Note that setting the title is required for the map
		# icon to be displayed
		black_schuck_quest.title = "PASSIVE_QUEST_UNKNOWN_TITLE"
		black_schuck_quest.map_marker_icons = [
			load("res://mods/black_shuck_changes/black_schuck.png")
		]

		mod_print("%s" % black_schuck_quest.map_marker_icons)

func mod_print(string: String):
	Console.writeLine("black_schuck_changes > %s" % string)
