extends Sprite2D
var is_selected = false
var move_menu_is_open = false
var cur_prov_controller = ""
var prov_controller = ""
var name_of_army_file = ""
var tile_located_on = ""
var nation_located_on = ""
var can_move_here = false
var army_size_label: Node = null

var army_base_data = {
	"army_tag" : "1",
	"infantry_num" : 0,
	"tile_located_on" : ""
	
}
var infantry_num = 0
func _ready():
	$".".name = "gd_holder"
	var army_gd_ref = get_path()
	Info_bank.army_gd_refs.append(army_gd_ref)
	print(str(Info_bank.army_gd_refs) + "132")
	army_size_label = $RichTextLabel
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	army_file.close()
	var army_parse = JSON.parse_string(army_text)
	var army_controller = army_parse.get("army_controller")

	var nation_res = "res://Map_data/nations/" + army_controller + ".json"
	var nation_file = FileAccess.open(nation_res,FileAccess.READ)
	var nation_text = nation_file.get_as_text()
	nation_file.close()
	var nation_parse = JSON.parse_string(nation_text)
	var nation_color = nation_parse.get("Nation_color")
	$RichTextLabel3.text = Info_bank.name_of_current_army_file
	$".".self_modulate = nation_color

func _process(delta: float = 1-2) -> void:
	update_ui()


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_released("click_left"):
		Info_bank.enemy_root_ref = self
		var player_army_name = Info_bank.selected_thing.name_of_army_file
		Info_bank.text_file("res://Map_data/armies/" + player_army_name + ".json", "")
		
		var player_army_parse = JSON.parse_string(Info_bank.text)
		var player_army_loc = player_army_parse.get("tile_located_on")
		
		Info_bank.text_file("res://Map_data/armies/" + name_of_army_file + ".json", "")
		var ai_army_parse = JSON.parse_string(Info_bank.text)
		
		var ai_army_loc = ai_army_parse.get("tile_located_on")
		Info_bank.text_file("res://Map_data/Provinces/" + player_army_loc, "")
		var parse = JSON.parse_string(Info_bank.text)
		var border_array = parse.get("bordered_provs")
		var can_attack = false
		for id in border_array:
			if id + ".json" == ai_army_loc:
				can_attack = true
		if can_attack == true:
			if Info_bank.attack_mode_active == true:
				
				var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
				var army_file = FileAccess.open(army_res, FileAccess.READ)
				var json_text = army_file.get_as_text()
				army_file.close()
				var army_parse_result = JSON.parse_string(json_text)
				var army_controller = army_parse_result.get("army_controller")
				var file_text = ""
				Info_bank.text_file("res://Map_data/Provinces/" + tile_located_on, file_text)
				var file_parse = JSON.parse_string(Info_bank.text)
				Info_bank.change_file("res://Map_data/Provinces/" + tile_located_on,file_parse,"has_army",false)
				
				
				
				var nat_res = "res://Map_data/nations/" + army_controller + ".json"
				var nat_file = FileAccess.open(nat_res, FileAccess.READ)
				var nat_text = nat_file.get_as_text()
				nat_file.close()
				var nat_parse = JSON.parse_string(nat_text)
				var ai_army_size = ai_army_parse.get("infantry_num")
				var player_army_size = player_army_parse.get("infantry_num")
				
				print(str(ai_army_parse)+"ai_army_parse"+ "133")
				print(str(player_army_parse)+"player_army-parse"+ "133")
				
				if ai_army_size > player_army_size:
					nat_parse["controlled_armies"] -= 1
					
					Info_bank.change_file("res://Map_data/armies/" + player_army_name + ".json", ai_army_parse, "infantry_num", int(-player_army_size))
					
					self.queue_free()
					var nat_string = JSON.stringify(nat_parse, "\t")
					nat_file = FileAccess.open(nat_res, FileAccess.WRITE)
					nat_file.store_string(nat_string)
					nat_file.close()
				else:
					Info_bank.change_file("res://Map_data/armies/" + name_of_army_file + ".json", player_army_parse, "infantry_num", int(-ai_army_size))
					
					Info_bank.selected_thing.queue_free()
					var nat_string = JSON.stringify(nat_parse, "\t")
					nat_file = FileAccess.open(nat_res, FileAccess.WRITE)
					nat_file.store_string(nat_string)
					nat_file.close()
				
				
				
				
				
				Info_bank.attack_mode_active = false
				Info_bank.selected_thing.deselected()
				Info_bank.new_scene.queue_free()
				
func loaded_in():
	var scene_root = $".."
	is_selected = false
	name_of_army_file = Info_bank.name_of_current_army_file
	tile_located_on = Info_bank.cur_ai_make_army + ".json"
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	army_file.close()
	var army_parse = JSON.parse_string(army_text)
	var infanty_num_for_label = army_parse.get("infantry_num")
	$RichTextLabel.text = str(infanty_num_for_label*10)
	var full_name = tile_located_on
	var dot_index = full_name.rfind(".")
	if dot_index != -1:
		full_name = full_name.substr(0, dot_index)
	$RichTextLabel2.text = full_name
	
	
	var prov_res = "res://Map_data/Provinces/" + tile_located_on
	var prov_file = FileAccess.open(prov_res, FileAccess.READ)
	var prov_text = prov_file.get_as_text()
	prov_file.close()
	var prov_parse = JSON.parse_string(prov_text)
	var prov_marker = prov_parse.get("unit_marker")
	scene_root.position = Vector2(prov_marker[0], prov_marker[1])
func _on_node_2d_child_entered_tree(node: Node) -> void:
	loaded_in()

func update_army_file():
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"

	# Open for reading
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	if army_file == null:
		push_error("Failed to open army file for reading: " + army_res)
		return

	var json_text = army_file.get_as_text()
	army_file.close()

	# Use static parse method
	var army_parse_result = JSON.parse_string(json_text)
	if typeof(army_parse_result) != TYPE_DICTIONARY:
		push_error("Failed to parse army JSON or data is not a dictionary")
		return

	# Modify the data
	army_parse_result["tile_located_on"] = Info_bank.HoveredProvince
	print("Modified army stats:", army_parse_result)

	# Open for writing
	army_file = FileAccess.open(army_res, FileAccess.WRITE)
	if army_file == null:
		push_error("Failed to open army file for writing: " + army_res)
		return

	army_file.store_string(JSON.stringify(army_parse_result, "\t"))  # Pretty print
	army_file.close()

	# Move unit and update UI
	move_menu_is_open = false

func update_ui():

	Info_bank.text_file("res://Map_data/armies/" + name_of_army_file + ".json", "")
	var army_parse = JSON.parse_string(Info_bank.text)
	var army_size = army_parse.get("infantry_num")

	$RichTextLabel.text = str(army_size)
