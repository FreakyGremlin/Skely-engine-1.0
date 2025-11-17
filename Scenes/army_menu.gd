extends Node2D
var name_of_army_file = ""
var infantry_num = 0
@onready var infantry_num_label = $RichTextLabel2
var tile_located_on = ""
var is_selected = true
var move_menu_is_open = false
var attack_menu_is_open = false
var cur_prov_controller = ""
var prov_controller = ""
var can_move_here = false
@onready var move_army = $TextureRect/Button
@onready var attack_button = $TextureRect/Button4
@onready var add_infantry = $TextureRect/Button2
@onready var annex_tile = $TextureRect/Button3
@onready var infantry_label = $RichTextLabel2
@onready var location_tile = $RichTextLabel
@onready var move_counter = $"move counter"
func _process(delta: float) -> void:
	if Info_bank.player_gold > 999:
		add_infantry.disabled = false
	else:
		add_infantry.disabled = true


func _enter_tree() -> void:
	var move_counter = $"move counter"
	var infantry_label = $RichTextLabel2
	var location_tile = $RichTextLabel
	tile_located_on = Info_bank.selected_prov
	name_of_army_file = Info_bank.name_of_current_army_file
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	print(army_res)
	army_file.close()
	var army_parse = JSON.parse_string(army_text)
	var move_points = army_parse.get("move_points")
	move_counter.text = str(move_points)
	var army_num = army_parse.get("infantry_num", 0)
	infantry_num = army_num
	infantry_label.text = str(infantry_num * 100)
	location_tile.text = Info_bank.HoveredProvinceName
	

func _exit_tree() -> void:
	infantry_num = 0
	var move_counter = $"move counter"
	var infantry_label = $RichTextLabel2
	var location_tile = $RichTextLabel
	tile_located_on = Info_bank.selected_prov
	name_of_army_file = Info_bank.name_of_current_army_file
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	print(army_res)
	army_file.close()
	var army_parse = JSON.parse_string(army_text)
	var move_points = army_parse.get("move_points")
	move_counter.text = str(move_points)
	var army_num = army_parse.get("infantry_num", 0)
	infantry_num = army_num
	infantry_label.text = str(infantry_num * 100)
	location_tile.text = Info_bank.HoveredProvinceName
	
func _on_button_2_pressed() -> void:
	if Info_bank.player_gold > 1000:
		var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
		Info_bank.player_gold -= 1000
		var army_file = FileAccess.open(army_res, FileAccess.READ)
		var army_text = army_file.get_as_text()
		army_file.close()
		var army_parse = JSON.parse_string(army_text)
		infantry_num += 1
		army_parse["infantry_num"] = infantry_num
		infantry_num_label.text = str(infantry_num * 100)
		army_file = FileAccess.open(army_res, FileAccess.WRITE)
		Info_bank.gold_counter_player.text = str(Info_bank.player_gold)
		army_file.store_string(JSON.stringify(army_parse, "\t"))
		army_file.close()

func _on_button_3_pressed() -> void:
	#ANNEX CODE
	if infantry_num * 100 > 100:
		Info_bank.name_of_current_army_file = name_of_army_file
		var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
		var army_file = FileAccess.open(army_res,FileAccess.READ)
		var army_text = army_file.get_as_text()
		army_file.close()
		var army_parse = JSON.parse_string(army_text)
		tile_located_on = army_parse.get("tile_located_on")
		
	# Get the hovered province name
		
		# Build the path to the province JSON file
		var prov_res = "res://Map_data/Provinces/" + tile_located_on
		# Open the file in read mode first
		var prov_file = FileAccess.open(prov_res, FileAccess.READ)

		if prov_file == null:
			print("Failed to open file for reading:", prov_res)
			return

		# Read the file content and parse the JSON
		var json_text = prov_file.get_as_text()
		prov_file.close()  # Always close files when done

		# Parse JSON
		var parse_result = JSON.parse_string(json_text)

		# Debug prints


		# Modify the data
		parse_result["countrie_color"] = Info_bank.ControlledNationColour
		parse_result["province_controller"] = Info_bank.ControlledNation
		# Now reopen the file in WRITE mode to save the changes
		prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
		
		var prov_string = JSON.stringify(parse_result, "\t")
		prov_file.store_string(prov_string)  # "\t" = pretty print
		prov_file.close()


		Info_bank.region_gd_ref.update_tiles()

		Info_bank.main_menu_is_active = false


func _on_button_pressed() -> void:
	if is_selected == true:
		if move_menu_is_open == false:
			move_army.disabled = true
			move_menu_is_open = true
			
		else:
			move_army.disabled = false
			move_menu_is_open = false
			



func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("click_left"):
		
		if move_menu_is_open == true:
			var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
			var army_file = FileAccess.open(army_res, FileAccess.READ)
			var json_text = army_file.get_as_text()
			army_file.close()
			var army_parse_result = JSON.parse_string(json_text)
			var move_points = army_parse_result.get("move_points")
			if move_points > 0:
				
				tile_located_on = army_parse_result.get("tile_located_on")
				
				# change the json adding
				
				var cur_prov_res = "res://Map_data/Provinces/" + tile_located_on
				var cur_prov_file = FileAccess.open(cur_prov_res, FileAccess.READ)
				var cur_prov_text = cur_prov_file.get_as_text()
				cur_prov_file.close()
				var cur_prov_parse = JSON.parse_string(cur_prov_text)
				var cur_border_provs = cur_prov_parse.get("bordered_provs")
				cur_prov_controller = cur_prov_parse.get("province_controller")
				cur_prov_parse["has_army"] = false
				for id in cur_border_provs:
					var prov_res = "res://Map_data/Provinces/" + id + ".json"
					var prov_file = FileAccess.open(prov_res, FileAccess.READ)
					var prov_text = prov_file.get_as_text()
					prov_file.close()

					var prov_parse = JSON.parse_string(prov_text)
					var tile_is_occupied = prov_parse.get("has_army")
					prov_controller = prov_parse.get("province_controller")
					
					if prov_controller == Info_bank.ControlledNation:
						if Info_bank.HoveredProvinceName == id and tile_is_occupied == false:
							can_move_here = true
					else:
						Info_bank.tooltip_text = "cannot move here"
						print(str(Info_bank.tooltip)+ "123")
					
				if can_move_here == true:
					var scene_root = Info_bank.army_root_ref
					# Read province data
					var prov_res = "res://Map_data/Provinces/" + Info_bank.HoveredProvince
					var prov_file = FileAccess.open(prov_res, FileAccess.READ)
					if prov_file == null:
						push_error("Failed to open province file: " + prov_res)
						return
					var prov_text = prov_file.get_as_text()
					prov_file.close()

					var prov_parse = JSON.parse_string(prov_text)
					var prov_marker = prov_parse.get("unit_marker")
					

					scene_root.position = Vector2(prov_marker[0], prov_marker[1])
					$RichTextLabel.text = Info_bank.HoveredProvinceName
					
					

					army_parse_result["tile_located_on"] = Info_bank.HoveredProvince
					army_parse_result["move_points"] -= 1
					Info_bank.change_file("res://Map_data/Provinces/" + Info_bank.HoveredProvince,prov_parse,"has_army",true)
					move_points = army_parse_result.get("move_points")
					
					move_counter.text = str(move_points)
					army_file = FileAccess.open(army_res, FileAccess.WRITE)
					var army_string = JSON.stringify(army_parse_result, "\t")
					
					army_file.store_string(army_string)
					army_file.close()
					move_menu_is_open = false
					
					
					can_move_here = false
					is_selected = false
					Info_bank.something_selected = false
					Info_bank.selected_tile = Info_bank.HoveredProvince
					
					cur_prov_file = FileAccess.open(cur_prov_res, FileAccess.WRITE)
					cur_prov_file.store_string(JSON.stringify(cur_prov_parse, "\t"))
					cur_prov_file.close()
		
		


func _on_button_4_pressed() -> void:
	if is_selected == true:
		if attack_menu_is_open == false:
			attack_button.disabled = true
			attack_menu_is_open = true
			Info_bank.attack_mode_active = true
			armies_to_attack()
		else:
			attack_button.disabled = false
			attack_menu_is_open = false
			Info_bank.attack_mode_active = false

func armies_to_attack():
	var main_node = Info_bank.main_scene_ref
	for id in Info_bank.armies_active_names:
		for Node in main_node.get_children():
			print(Node.name + "nodename")
			if Node.name == id:
				print("node modulated")
				Node.modulate = Color()
