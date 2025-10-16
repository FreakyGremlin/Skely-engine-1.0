extends Node2D




func _enter_tree() -> void:
	var prov_lable = $"ProvinceUiBackground/Name plate"
	var nation_lable = $"ProvinceUiBackground/Name plate2"
	prov_lable.text = Info_bank.selected_prov_name
	nation_lable.text = Info_bank.full_nation_name
	Info_bank.menu_is_active = true
