extends Button
@onready var button_marker = $"."

func _on_pressed() -> void:
	move_army()
func move_army():
	var selected_army = Info_bank.selected_thing
	selected_army.global_position = button_marker.global_position
	print(selected_army.position)
	print(button_marker.global_position)
	print(button_marker.position)
	self.queue_free()
	
