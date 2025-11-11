extends Control
@onready var turn_button = $CanvasLayer2/TextureButton
@onready var army_counter = $"CanvasLayer2/army counter"
func _ready() -> void:
	Info_bank.gold_counter_player = $"CanvasLayer2/gold counter"
	Info_bank.canvas_ref = $CanvasLayer2
func _process(delta: float) -> void:
	army_counter.text = str(Info_bank.players_armies_num)
func _on_texture_button_pressed() -> void:
	print(str(Info_bank.is_player_active) + "is active" )
	if Info_bank.is_player_active == true:
		var controlled_provs = 0
		for Node in Info_bank.region_node_ref.get_children():
			var dict_res = "res://Map_data/regions.txt"
			var dict_file = FileAccess.open(dict_res, FileAccess.READ)
			var dict_text = dict_file.get_as_text()
			dict_file.close()
			var dict_parse = JSON.parse_string(dict_text)
			var prov_name = dict_parse.get(Node.name)
			print(prov_name)
			
			
			
			
			
			
			var prov_res = "res://Map_data/Provinces/" + prov_name + ".json"
			print(prov_res)
			var prov_file = FileAccess.open(prov_res, FileAccess.READ)
			var prov_text = prov_file.get_as_text()
			prov_file.close()
			var prov_parse = JSON.parse_string(prov_text)
			var prov_controller = prov_parse.get("province_controller")
			if prov_controller == Info_bank.ControlledNation:
				
				controlled_provs += 1
				print(controlled_provs)
			var nat_res = "res://Map_data/nations/" + Info_bank.ControlledNation + ".json"
			var nat_file = FileAccess.open(nat_res, FileAccess.READ)
			var nat_text = nat_file.get_as_text()
			nat_file.close()
			var nat_parse = JSON.parse_string(nat_text)
			nat_parse["Controlled_provinces"] = controlled_provs
			
			nat_file = FileAccess.open(nat_res, FileAccess.WRITE)
			var nat_string = JSON.stringify(nat_parse, "\t")
			nat_file.store_string(nat_string)
			nat_file.close()
			
		for int in Info_bank.players_armies_num + 1:
			if int > 0:
				var army_res = "res://Map_data/armies/" + "army" + str(int) + ".json"
				print(army_res)
				var army_file = FileAccess.open(army_res,FileAccess.READ)
				var army_text = army_file.get_as_text()
				army_file.close()
				var army_parse = JSON.parse_string(army_text)
				army_parse["move_points"] = 1
				var army_string = JSON.stringify(army_parse, "\t")
				print(army_string + "armyfile")
				army_file = FileAccess.open(army_res, FileAccess.WRITE)
				army_file.store_string(army_string)
				army_file.close()
		Info_bank.player_revenue = (controlled_provs * 100)-(Info_bank.players_armies_num * 100)
		
		
		Info_bank.is_player_active = false
		Info_bank.player_gold += Info_bank.player_revenue
		Info_bank.gold_counter_player.text = str(Info_bank.player_gold)
		var main_script = $".."
		
		main_script.ai_turn()
	
