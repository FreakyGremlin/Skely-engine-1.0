extends Node2D
var selected_prov = Info_bank.selected_prov
var selected_nat = ""


func _enter_tree() -> void:
	var prov_lable = $"ProvinceUiBackground/Name plate"
	var nation_lable = $"ProvinceUiBackground/Name plate2"
	prov_lable.text = Info_bank.selected_prov_name
	
	Info_bank.text_file("res://Map_data/Provinces/" + selected_prov, "")
	var prov_parse = JSON.parse_string(Info_bank.text)
	var prov_controller = prov_parse.get("province_controller")
	selected_nat = prov_controller
	
	nation_lable.text = Info_bank.full_nation_name
	Info_bank.menu_is_active = true


func _on_button_pressed() -> void:
	#DECLARE WAR
	Info_bank.text_file("res://Map_data/nations/Nations diplo/" + selected_nat + ".json", "")
	var diplo_parse = JSON.parse_string(Info_bank.text)
	Info_bank.change_file("res://Map_data/nations/Nations diplo/" + selected_nat + ".json",diplo_parse,'"'+Info_bank.ControlledNation+ '"', "war")
	set_war_controlled_nat()
	
	Info_bank.text_file("res://Map_data/nations/" + selected_nat + ".json", "")
	var nat_parse = JSON.parse_string(Info_bank.text)
	var war_array = nat_parse.get("at_war_with")
	
	war_array.append(Info_bank.ControlledNation)
	nat_parse["at_war_with"] = war_array
	var nat_string = JSON.stringify(nat_parse, "\t")
	var nat_file = FileAccess.open("res://Map_data/nations/" + selected_nat + ".json",FileAccess.WRITE)
	nat_file.store_string(nat_string)
	nat_file.close()
	print(str(war_array)+ "102")
	print(str(nat_parse)+ "102")


func set_war_controlled_nat():
	Info_bank.text_file("res://Map_data/nations/Nations diplo/" + Info_bank.ControlledNation + ".json", "")
	var diplo_parse = JSON.parse_string(Info_bank.text)
	Info_bank.change_file("res://Map_data/nations/Nations diplo/" + Info_bank.ControlledNation + ".json",diplo_parse,'"'+selected_nat+ '"', "war")
	
