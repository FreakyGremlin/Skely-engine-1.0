extends Control
var is_visible = false 
func _ready() -> void:
	Info_bank.tooltip = $RichTextLabel
func _input(event: InputEvent) -> void:
	
	
	if Input.is_action_just_pressed("tooltip"):
		if is_visible == false:
			is_visible = true
			$RichTextLabel.visible = true
		else:
			is_visible = false
			$RichTextLabel.visible = false
			
func _process(delta: float) -> void:
	$".".global_position = get_global_mouse_position()
	$RichTextLabel.text = Info_bank.tooltip_text
	
