extends Node2D
var new_scene: Node = null
func _enter_tree() -> void:
	Info_bank.menu_is_active = true
func _on_button_1_pressed() -> void:
	Info_bank.ControlledNation = Info_bank.HoveredNation
	Info_bank.ControlledNationColour = Info_bank.HoveredNationColour
	Info_bank.main_menu.queue_free()
	Info_bank.main_menu_is_active = false

func _on_button_2_pressed() -> void:
	# Get the hovered province name
	var HoveredProvince = Info_bank.selected_prov

	# Build the path to the province JSON file
	var prov_res = "res://Map_data/Provinces/" + HoveredProvince

	# Open the file in read mode first
	var prov_file = FileAccess.open(prov_res, FileAccess.READ)

	if prov_file == null:
		print("Failed to open file for reading:", prov_res)
		return

	# Read the file content and parse the JSON
	var json_text = prov_file.get_as_text()
	prov_file.close()  # Always close files when done

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)

	if parse_result != OK:
		print("Failed to parse JSON:", json.get_error_message())
		return

	var prov_stats = json.data

	# Debug prints
	print(Info_bank.HoveredNation)
	print(Info_bank.HoveredNationColour)
	print(Info_bank.ControlledNation)
	print(Info_bank.ControlledNationColour)

	# Modify the data
	prov_stats["countrie_color"] = Info_bank.ControlledNationColour
	prov_stats["province_controller"] = Info_bank.ControlledNation

	print(prov_stats)

	# Now reopen the file in WRITE mode to save the changes
	prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
	if prov_file == null:
		print("Failed to open file for writing:", prov_res)
		return

	# Write updated JSON to file
	prov_file.store_string(JSON.stringify(prov_stats, "\t"))  # "\t" = pretty print
	prov_file.close()

	print("Province JSON updated successfully.")
	Info_bank.region_gd_ref.update_tiles()

	Info_bank.main_menu.queue_free()
	Info_bank.main_menu_is_active = false

func _on_button_3_pressed() -> void:
	print(str(Info_bank.menu_is_active) + str(1))
	var canvas_layer: CanvasLayer = null
	if Info_bank.menu_is_active == true:
		# Look for CanvasLayer in the current scene
		for node in get_tree().get_current_scene().get_children():
			if node is CanvasLayer:
				canvas_layer = node
				break
		if canvas_layer:
			var scene_to_instantiate = load("res://Scenes/province_menu.tscn")
			Info_bank.new_scene = scene_to_instantiate.instantiate()  # Use global new_scene
			canvas_layer.add_child(Info_bank.new_scene)
			Info_bank.new_scene.global_position = Vector2(200, 700)
			self.queue_free()
			Info_bank.menu_is_active = true


func _on_button_4_pressed() -> void:
	var prov_res = "res://Map_data/Provinces/" + Info_bank.selected_prov
	var prov_file = FileAccess.open(prov_res, FileAccess.READ)
	var prov_text = prov_file.get_as_text()
	prov_file.close()
	var prov_parse = JSON.parse_string(prov_text)
	var tile_has_army = prov_parse.get("has_army")
	print(tile_has_army)
	if tile_has_army == false:
		prov_parse["has_army"] = true
		var prov_string = JSON.stringify(prov_parse, "\t")
		print(prov_parse)
		
		var canvas_layer: CanvasLayer = null
		Info_bank.army_num += 1
		Info_bank.name_of_current_army_file = "army" + str(Info_bank.army_num)
		var army_base_data = {
			"army_tag" : "1",
			"infantry_num" : 0,
			"tile_located_on" : Info_bank.selected_prov_name
			
		}
		Info_bank.name_of_army_file = "army" + str(Info_bank.army_num)
		var json_string = JSON.stringify(army_base_data, "\t")
		var army_file = FileAccess.open("res://Map_data/armies/" + "army" + str(Info_bank.army_num) + ".json", FileAccess.WRITE)
		army_file.store_string(json_string)
		army_file.close()
		var scene_to_instantiate = load("res://Map_data/armies/army.tscn")
		var new_scene = scene_to_instantiate.instantiate()
		prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
		prov_file.store_string(prov_string)
		prov_file.close()

		
		get_tree().get_root().get_child(1).add_child(new_scene)
		
