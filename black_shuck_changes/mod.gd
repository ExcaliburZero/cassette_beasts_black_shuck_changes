extends ContentInfo

var black_shuck_quest_weight: float = 1.0 setget _set_black_shuck_quest_weight # Double the default weight of 0.5
var black_shuck_quest_map_icon: bool = true setget _set_black_shuck_quest_map_icon
var black_shuck_chase_chance: float = 0.1 # 10%, ten times the default chance of 1%

var black_shuck_quests: Array = []
var map_displays: Array = []

const MODUTILS: Dictionary = {
	"settings": [
		{
			"property": "black_shuck_quest_weight",
			"type": "options",
			"label": "Black Shuck spawn frequency",
			"values": [
				0.0,
				0.5,
				1.0,
				99999.0,
			],
			"value_labels": [
				"Never",
				"Default",
				"Double",
				"All the time!"
			]
		},
		{
			"property": "black_shuck_quest_map_icon",
			"type": "options",
			"label": "Black Shuck map icon",
			"values": [
				false,
				true,
			],
			"value_labels": [
				"No",
				"Yes",
			]
		},
	]
}

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

	# Setup a callback to grab the MapDisplay so we can update it when changing the Black Shuck map
	# icon setting
	DLC.mods_by_id.cat_modutils.callbacks.connect_scene_ready(
		"res://nodes/map_display/MapDisplay.tscn",
		self,
		"_on_MapDisplay_ready"
	)

	# Setup a callback to change Black Shuck's chase rate
	DLC.mods_by_id.cat_modutils.callbacks.connect_scene_ready(
		"res://world/quest_scenes/passive/BlackShuck.tscn",
		self,
		"_on_BlackShuck_ready"
	)

	mod_print("Finished loading Black Shuck changes mod.")

func _set_black_shuck_quest_weight(weight: float):
	black_shuck_quest_weight = weight
	set_black_shuck_quest_weight(black_shuck_quest_weight)

func _set_black_shuck_quest_map_icon(enable: bool) -> void:
	black_shuck_quest_map_icon = enable

	for quest in black_shuck_quests:
		set_BlackShuckQuest_map_icon(quest)

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

func _on_MapDisplay_ready(scene: Node) -> void:
	mod_print("There's a MapDisplay scene.")

	# Clear out any built up old MapDisplays to avoid memory leaks
	var freed_map_displays = []
	for map_display in map_displays:
		if not is_instance_valid(map_display) or map_display.is_queued_for_deletion():
			freed_map_displays.push_back(map_display)

	mod_print("Found %s freed MapDisplays. Freeing them..." % freed_map_displays.size())
	if freed_map_displays.size() > 0:
		for map_display in freed_map_displays:
			map_displays.erase(map_display)

	# Add the new MapDisplay to the list
	map_displays.push_back(scene)
	mod_print("Added new MapDisplay to list. (size=%s)" % map_displays.size())

func _on_BlackShuckQuest_ready(scene: Node) -> void:
	mod_print("There's a Black Shuck quest.")

	set_BlackShuckQuest_map_icon(scene)

	# Store the quest so that if the player decides to change the setting we can update the map icon
	# accordingly.
	black_shuck_quests.push_back(scene)

	# Remove old entries from the list if it gets really long. This should only happen for very long
	# play sessions, but since it could cause a memory leak in that case and it looks easy to fix,
	# might as well fix it now.
	if black_shuck_quests.size() > 100:
		black_shuck_quests = black_shuck_quests.slice(50, black_shuck_quests.size())

func set_BlackShuckQuest_map_icon(scene: Node) -> void:
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
	else:
		mod_print("Disabling Black Shuck map icon for this quest")
		var black_shuck_quest = scene

		mod_print("%s" % black_shuck_quest)
		mod_print("%s" % black_shuck_quest.map_marker_icons)

		# Remove the quest title and map icon
		black_shuck_quest.title = ""
		black_shuck_quest.map_marker_icons = []

		mod_print("%s" % black_shuck_quest.map_marker_icons)


	for map_display in map_displays:
		mod_print("Updating MapDisplay quest markers.")
		map_display.quest_markers_dirty = true
		map_display.update_quest_markers()

func _on_BlackShuck_ready(scene: Node) -> void:
	mod_print("Black Shuck has spawned.")

	var black_shuck = scene;
	mod_print("black_shuck: %s" % black_shuck)
	mod_print("previous chase chance: %s" % black_shuck.chase_chance)

	# Change the chase rate
	black_shuck.chase_chance = black_shuck_chase_chance
	mod_print("new chase chance: %s" % black_shuck.chase_chance)

func mod_print(string: String):
	Console.writeLine("black_shuck_changes > %s" % string)
