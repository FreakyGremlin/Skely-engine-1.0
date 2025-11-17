extends Sprite2D
var is_selected = false
var move_menu_is_open = false
@onready var selected_indicator = $Sprite2D2
var cur_prov_controller = ""
var prov_controller = ""
var name_of_army_file = ""
var tile_located_on = ""
var nation_located_on = ""
var can_move_here = false
var army_base_data = {
	"army_tag" : "1",
	"infantry_num" : 0,
	"tile_located_on" : ""
	
}
var infantry_num = 0
func _ready():
		selected_indicator.visible = false
func deselected():
	is_selected = false
	selected_indicator.visible = false
	Info_bank.something_selected = false
	Info_bank.menu_is_active = false
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_released("click_left"):
		print(Info_bank.something_selected)
		print(Info_bank.main_menu_is_active)
		if is_selected == false:
			
			if Info_bank.something_selected == false:
				selected_indicator.visible = true
				Info_bank.name_of_current_army_file = name_of_army_file
				var canvas_layer: CanvasLayer = null
				if Info_bank.menu_is_active == false:
					var scene_to_instantiate = load("res://Scenes/Army_menu.tscn")
					Info_bank.new_scene = scene_to_instantiate.instantiate()  # Use global new_scene
					Info_bank.canvas_ref.add_child(Info_bank.new_scene)
					Info_bank.new_scene.global_position = Vector2(200, 700)
					Info_bank.menu_is_active = true
					Info_bank.army_menu = Info_bank.new_scene
					print("scene made")
				is_selected = true
				Info_bank.army_root_ref = $".."
				Info_bank.something_selected = true
				Info_bank.selected_thing = self
				var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
				var army_file = FileAccess.open(army_res, FileAccess.READ)
				var army_text = army_file.get_as_text()
				army_file.close()
				var army_parse = JSON.parse_string(army_text)
				var army_num = army_parse.get("infantry_num", 0)
				infantry_num = army_num
			
		else:
			Info_bank.new_scene.queue_free()
			Info_bank.menu_is_active = false
			is_selected = false
			
			Info_bank.army_root_ref = null
			selected_indicator.visible = false
			Info_bank.something_selected = false
func loaded_in():
	var scene_root = $".."
	is_selected = false
	name_of_army_file = Info_bank.name_of_current_army_file
	tile_located_on = Info_bank.selected_prov
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	army_file.close()
	var army_parse = JSON.parse_string(army_text)
	var infanty_num_for_label = army_parse.get("infantry_num")
	
	var full_name = tile_located_on
	var dot_index = full_name.rfind(".")
	if dot_index != -1:
		full_name = full_name.substr(0, dot_index)
	
	
	
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

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("click_left"):
		
		if move_menu_is_open == true:
			var cur_prov_res = "res://Map_data/Provinces/" + tile_located_on
			var cur_prov_file = FileAccess.open(cur_prov_res, FileAccess.READ)
			var cur_prov_text = cur_prov_file.get_as_text()
			cur_prov_file.close()
			var cur_prov_parse = JSON.parse_string(cur_prov_text)
			var cur_border_provs = cur_prov_parse.get("bordered_provs")
			cur_prov_controller = cur_prov_parse.get("province_controller")
			cur_prov_parse["has_army"] = false
			for id in cur_border_provs:
				if Info_bank.HoveredProvinceName == id:
					can_move_here = true
					print(id)
					print(can_move_here)
					print(cur_border_provs)
					print(Info_bank.HoveredProvinceName)
			if can_move_here == true:
				var scene_root = $".."
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
				prov_controller = prov_parse.get("province_controller")

				scene_root.position = Vector2(prov_marker[0], prov_marker[1])
				$RichTextLabel2.text = Info_bank.HoveredProvinceName
				update_army_file()
				can_move_here = false
				is_selected = false
				selected_indicator.visible = false
				Info_bank.something_selected = false
				tile_located_on = Info_bank.HoveredProvince
				Info_bank.selected_tile = Info_bank.HoveredProvince
				print(tile_located_on + "tile")
				
				cur_prov_file = FileAccess.open(cur_prov_res, FileAccess.WRITE)
				cur_prov_file.store_string(JSON.stringify(cur_prov_parse, "\t"))
				cur_prov_file.close()
