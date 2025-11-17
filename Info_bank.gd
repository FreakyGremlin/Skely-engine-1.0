extends Node


# variables
var ControlledNation = ""
var HoveredNation = ""
var HoveredNationColour = ""
var HoveredProvince = ""
var HoveredProvinceName = ""
var ControlledNationColour = ""
var full_nation_name = ""
var something_selected = false
var selected_thing = ""
var name_of_army_file = ""
var army_menu_is_active = false
var menu_is_active = false
var last_mouse_position
var main_menu_is_active = false
var main_menu = ""
var region_gd_ref = ""
var selected_prov = ""
var selected_prov_name = ""
var selected_tile = ""
var new_scene: Node = null
@onready var root_scene_node : Node = $"."
var army_root_ref: Node = null
var name_of_current_army_file = ""
var army_num = 0
var region_name = ""
var debug_mode_on = false
var is_player_active = true
var player_gold = 0
var army_menu: Node = null
var gold_counter_player: Node = null
var nations_active = 4
var cur_ai_make_army = ""
var region_node_ref : Node = null
var canvas_ref : Node = null
var player_revenue = 0
var players_armies_num = 0
var enemy_root_ref : Node = null
var attack_mode_active = false
var armies_active_names = []
var main_scene_ref : Node = null
var active_armies = 0
var army_gd_refs = []






#funcs
var text = ""
func text_file(Res,text):
	print(Res + "restag")
	var file_res = Res
	var file = FileAccess.open(Res, FileAccess.READ)
	var file_text = file.get_as_text()
	text = file_text
	file.close()
	Info_bank.text = file_text
	print(text + "text")
	return text

func change_file(res,parse,subject,edit):
	if edit is int:
		print(str(parse) + "parsed"+"parse")
		print(str(edit) + "parsed"+"edit")
		print(str(subject) + "parsed"+"subject")
		print(res + "parsed"+"res")
		var file = FileAccess.open(res,FileAccess.WRITE)
		parse[subject] += edit
		var string = JSON.stringify(parse, "\t")
		file.store_string(string)
		file.close()
	else:
		print(str(parse) + "parsed")
		var file = FileAccess.open(res,FileAccess.WRITE)
		parse[subject] = edit
		var string = JSON.stringify(parse, "\t")
		file.store_string(string)
		file.close()
