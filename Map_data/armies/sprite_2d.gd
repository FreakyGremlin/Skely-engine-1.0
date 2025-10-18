extends Sprite2D
var is_selected = false
var move_menu_is_open = false
@onready var selected_indicator = $Sprite2D2
@onready var move_button = $Button
var name_of_army_file = ""
var tile_located_on = ""
var army_base_data = {
	"army_tag" : "1",
	"infantry_num" : 0,
	"tile_located_on" : ""
	
}
var infantry_num = 0
func _ready():
		selected_indicator.visible = false
		move_button.visible = false
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_released("click_left"):
		if is_selected == false:
			if Info_bank.something_selected == false:
				selected_indicator.visible = true
				move_button.visible = true
				is_selected = true
				Info_bank.something_selected = true
				Info_bank.selected_thing = self
				
		else:
			is_selected = false
			move_button.visible = false
			selected_indicator.visible = false
			Info_bank.something_selected = false


func _on_node_2d_child_entered_tree(node: Node) -> void:
	is_selected = false
	name_of_army_file = Info_bank.name_of_current_army_file



func _on_button_pressed() -> void:
	if is_selected == true:
		if move_menu_is_open == false:
			pass


func _on_button_2_pressed() -> void:
	var army_res = "res://Map_data/armies/" + name_of_army_file + ".json"
	print(name_of_army_file)
	var army_file = FileAccess.open(army_res, FileAccess.READ)
	var army_text = army_file.get_as_text()
	army_file.close
	var army_parse = JSON.parse_string(army_text)
	infantry_num += 1
	army_parse["infantry_num"] = infantry_num
	print(infantry_num)
	print(army_parse)
	
	army_file = FileAccess.open(army_res, FileAccess.WRITE)
	army_file.store_string(JSON.stringify(army_parse, "\t"))
	army_file.close()
	
	
	
