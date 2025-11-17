extends Node2D
var selected_prov = Info_bank.selected_prov



func _enter_tree() -> void:
	var prov_lable = $"ProvinceUiBackground/Name plate"
	var nation_lable = $"ProvinceUiBackground/Name plate2"
	prov_lable.text = Info_bank.selected_prov_name
	nation_lable.text = Info_bank.full_nation_name
	Info_bank.menu_is_active = true


func _on_button_pressed() -> void:
	#DECLARE WAR
	
