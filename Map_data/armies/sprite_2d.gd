extends Sprite2D
var is_selected = false
@onready var selected_indicator = $"../Sprite2D2"
var name_of_army_file = ""

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_released("click_left"):
		if is_selected == false:
			if Info_bank.something_selected == false:
				is_selected = true
				Info_bank.something_selected = true
				Info_bank.selected_thing = self
				print(Info_bank.selected_thing)
				print(is_selected)
				selected_indicator.visible = true
		else:
			is_selected = false
			selected_indicator.visible = false
			Info_bank.something_selected = false
			print(is_selected)


func _on_node_2d_child_entered_tree(node: Node) -> void:
	name_of_army_file = Info_bank.name_of_army_file
	print(name_of_army_file)
	print("worked")
