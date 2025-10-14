extends Node2D




func _enter_tree() -> void:
	var prov_lable = $ProvinceUiBackground/RichTextLabel
	prov_lable.text = Info_bank.selected_prov_name
