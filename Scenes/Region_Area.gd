extends Area2D
var jsondata : Dictionary = {}
var region_name = ""
var nation_color = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_child_entered_tree(node):
	var Province_data = str(region_name) + ".json"
	var prov_res = "res://Map_data/Provinces/" + Province_data
	var prov_file := FileAccess.open(prov_res, FileAccess.READ)
	
	if prov_file:
		var file_text := prov_file.get_as_text()
		prov_file.close()  # Always close the file when done

		var prov_json_data = JSON.parse_string(file_text)
		
		if typeof(prov_json_data) == TYPE_DICTIONARY:
			var prov_controller = prov_json_data.get("province_controller", "Controller not found")
			var nation_name = prov_controller + ".json"
			var Nation_info = "res://Map_data/nations/" + nation_name
			var nation_file = FileAccess.open(Nation_info, FileAccess.READ)
			var nation_text = nation_file.get_as_text()
			var parsed_nat_text = JSON.parse_string(nation_text)
			var nation_color = parsed_nat_text.get("Nation_color", "nation color not found")
			if node.is_class("Polygon2D"):
				node.color = Color(nation_color)
				
		else:
			push_error("Parsed JSON is not a dictionary. Check the file content.")
	else:
		push_error("Failed to open file: " + prov_res)
	


func _on_mouse_entered():
	var Province_data = str(region_name) + ".json" 
	Info_bank.HoveredProvince = Province_data
	
	for node in get_children():
		if node.is_class("Polygon2D"):
			node.color = Color(1,1,1,1)
		var prov_res = "res://Map_data/Provinces/" + Province_data
		var prov_file := FileAccess.open(prov_res, FileAccess.READ)
		
		if prov_file:
			var file_text := prov_file.get_as_text()
			prov_file.close()  # Always close the file when done
			var json_data = JSON.parse_string(file_text)
			
			if typeof(json_data) == TYPE_DICTIONARY:
				var prov_controller = json_data.get("province_controller", "Controller not found")
				var nation_name = prov_controller + ".json"
				Info_bank.HoveredNation = prov_controller
				
				var Nation_info = "res://Map_data/nations/" + nation_name
				var nation_file = FileAccess.open(Nation_info, FileAccess.READ)
				var nation_text = nation_file.get_as_text()
				var parsed_nat_text = JSON.parse_string(nation_text)
				var nation_color = parsed_nat_text.get("Nation_color", "nation color not found")
				var full_nation_name = parsed_nat_text.get("Nation_name", "nation name not found")
				
				Info_bank.full_nation_name = full_nation_name
				Info_bank.HoveredNationColour = nation_color
				
				
				
			else:
				push_error("Parsed JSON is not a dictionary. Check the file content.")
		else:
			push_error("Failed to open file: " + prov_res)
	

func _on_mouse_exited():
	var Province_data = str(region_name) + ".json"
	var prov_res = "res://Map_data/Provinces/" + Province_data
	var prov_file := FileAccess.open(prov_res, FileAccess.READ)
	
	if prov_file:
		var file_text := prov_file.get_as_text()
		prov_file.close()  # Always close the file when done

		var prov_json_data = JSON.parse_string(file_text)
		
		if typeof(prov_json_data) == TYPE_DICTIONARY:
			var prov_controller = prov_json_data.get("province_controller", "Controller not found")
			var nation_name = prov_controller + ".json"
			var Nation_info = "res://Map_data/nations/" + nation_name
			var nation_file = FileAccess.open(Nation_info, FileAccess.READ)
			var nation_text = nation_file.get_as_text()
			var parsed_nat_text = JSON.parse_string(nation_text)
			var nation_color = parsed_nat_text.get("Nation_color", "nation color not found")
			for node in get_children():
				if node.is_class("Polygon2D"):
					node.color = Color(nation_color)
		else:
			push_error("Parsed JSON is not a dictionary. Check the file content.")
	else:
		push_error("Failed to open file: " + prov_res)
	
	
