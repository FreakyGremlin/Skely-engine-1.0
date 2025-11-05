extends Node2D
var new_scene: Node = null
func _enter_tree() -> void:
	if Info_bank.ControlledNation == "":
		print(Info_bank.ControlledNation)
	if Info_bank.HoveredNation == Info_bank.ControlledNation:
		$Button1.disabled = true
		$Button1/Button2.disabled = true
		$Button1/Button2.disabled = true
		$Button1/Button2/Button4.disabled = false
	else:
		if Info_bank.ControlledNation == "":
			$Button1/Button2.disabled = true
		else:
			$Button1/Button2.disabled = false
		$Button1.disabled = false
		$Button1/Button2/Button4.disabled = true
	
	
	Info_bank.menu_is_active = true
func _on_button_1_pressed() -> void:
	Info_bank.ControlledNation = Info_bank.HoveredNation
	Info_bank.ControlledNationColour = Info_bank.HoveredNationColour
	Info_bank.main_menu.queue_free()
	Info_bank.main_menu_is_active = false

func _on_button_2_pressed() -> void:
	# Get the hovered province name
	var HoveredProvince = Info_bank.selected_prov
	if HoveredProvince == null or HoveredProvince == "":
		push_error("No hovered province selected.")
		return

	# Build the path to the province JSON file
	var prov_res = "res://Map_data/Provinces/" + HoveredProvince
	if not FileAccess.file_exists(prov_res):
		push_error("Province file does not exist: " + prov_res)
		return

	# --- READ ---
	var prov_file := FileAccess.open(prov_res, FileAccess.READ)
	if prov_file == null:
		push_error("Failed to open file for reading: " + prov_res)
		return

	var json_text := prov_file.get_as_text()
	prov_file.close()

	# --- PARSE ---
	var parse_result = JSON.parse_string(json_text)
	if typeof(parse_result) != TYPE_DICTIONARY:
		push_error("Invalid JSON structure in: " + prov_res)
		return

	# --- DEBUG PRINTS ---
	print("Hovered nation:", Info_bank.HoveredNation)
	print("Hovered nation colour:", Info_bank.HoveredNationColour)
	print("Controlled nation:", Info_bank.ControlledNation)
	print("Controlled nation colour:", Info_bank.ControlledNationColour)

	# --- MODIFY DATA ---
	parse_result["countrie_color"] = Info_bank.ControlledNationColour
	parse_result["province_controller"] = Info_bank.ControlledNation
	print("Updated data:", parse_result)

	# --- WRITE UPDATED JSON ---
	prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
	if prov_file == null:
		push_error("Failed to open file for writing: " + prov_res)
		return

	var prov_string := JSON.stringify(parse_result, "\t")
	prov_file.store_string(prov_string)
	prov_file.close()

	print("Province JSON updated successfully.")

	# --- SAFE TILE UPDATE ---
	if is_instance_valid(Info_bank.region_gd_ref):
		print("Updating tiles for:", Info_bank.region_gd_ref.name)
		Info_bank.region_gd_ref.update_tiles()
	else:
		push_warning("region_gd_ref is invalid or already freed, skipping update.")


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
			"tile_located_on" : Info_bank.selected_prov_name + ".json",
			"army_controller" : Info_bank.ControlledNation
			
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
		
