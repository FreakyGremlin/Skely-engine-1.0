extends Node2D
var region_name = ""
var _last_mouse_position
var selected_nation_name 
@onready var _pm = $PopupMenu
var prov_stats = {
"prov_tag": "",
"name": "",
"countrie_color": "",
"province_controller": ""
}
var selected_army_menu = ""
var army_num = 1
var hovered_nation_name = "best"
enum PopupIds {
	Check_Nation,
	set_prov_owner,
	Set_controlled_nation,
	Create_army,
	Nation_name,
	army_menu_popup
}

@onready var mapImage = $RegionMap
# Called when the node enters the scene tree for the first time.
func _ready():
	load_regions()
	_pm.add_item("Check Nation", PopupIds.Check_Nation)
	_pm.add_item("Set Owner Of Province", PopupIds.set_prov_owner)
	_pm.add_item("Set controlled nation", PopupIds.Set_controlled_nation)
	_pm.add_item("create army", PopupIds.Create_army)
	_pm.add_item("", PopupIds.Nation_name)
	_pm.add_item("open army menu", PopupIds.army_menu_popup)
	_pm.connect("id_pressed", Callable (self,"_on_PopupMenu_id_pressed"))
	_pm.connect("index_pressed", Callable (self,"_on_PopupMenu_index_pressed"))
	$PopupMenu.set_item_disabled(4, true)
	
func _input(event):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		var main_menu = load("res://Scenes/main_menu.tscn")
		_last_mouse_position = get_global_mouse_position()
		Info_bank.last_mouse_position = _last_mouse_position
		print(_last_mouse_position)
		print(Info_bank.last_mouse_position)
		if Info_bank.main_menu_is_active == false:
			var new_scene = main_menu.instantiate()
			selected_army_menu = new_scene
			add_child(new_scene)
			Info_bank.main_menu = new_scene
			new_scene.position = _last_mouse_position
			Info_bank.main_menu_is_active = true
		else:
			Info_bank.main_menu.queue_free()
			Info_bank.main_menu_is_active = false
		print(Info_bank.HoveredNation)
		print(Info_bank.HoveredNationColour)
		print(Info_bank.ControlledNation)
		print(Info_bank.ControlledNationColour)
		if Info_bank.something_selected == true:
			$PopupMenu.set_item_disabled(5, false)
		else:
			$PopupMenu.set_item_disabled(5, true)
		if Info_bank.HoveredNation == Info_bank.ControlledNation:
			$PopupMenu.set_item_disabled(3, false)
			$PopupMenu.set_item_disabled(2, true)
			$PopupMenu.set_item_disabled(1, true)
		else:
			$PopupMenu.set_item_disabled(3, true)
			$PopupMenu.set_item_disabled(2, false)
			$PopupMenu.set_item_disabled(1, false)
	var Province_data = str(region_name) + ".json"
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var prov_res = "res://Map_data/Provinces/" + Province_data
		var prov_file := FileAccess.open(prov_res, FileAccess.READ)
		
		if prov_file:
			var file_text := prov_file.get_as_text()
			prov_file.close()  # Always close the file when done

			var json_data = JSON.parse_string(file_text)
			
			if typeof(json_data) == TYPE_DICTIONARY:
				var prov_controller = json_data.get("province_controller", "Controller not found")
				var nation_name = prov_controller + ".json"
				var Nation_info = "res://Map_data/nations/" + nation_name
				var nation_file = FileAccess.open(Nation_info, FileAccess.READ)
				var nation_text = nation_file.get_as_text()
				var parsed_nat_text = JSON.parse_string(nation_text)
				var selected_nation_name = parsed_nat_text.get("nation_name", "nation color not found")
				
			else:
				push_error("Parsed JSON is not a dictionary. Check the file content.")
		else:
			push_error("Failed to open file: " + prov_res)
		
	
	
	if Input.is_action_just_pressed("test_imput_1"):
		var scene_to_instantiate = load("res://Scenes/province_menu.tscn")
		var new_scene = scene_to_instantiate.instantiate()
		add_child(new_scene)
		new_scene.position = _last_mouse_position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hovered_nation_name = Info_bank.full_nation_name
	$PopupMenu.set_item_text(4, hovered_nation_name)
	pass
func load_regions():
	#loads the map texture and sets the provinces
	var image = mapImage.get_texture().get_image()
	var pixel_color_dict = get_pixel_color_dict(image)
	var regions_dict = import_file("res://Map_data/regions.txt")
	
	for region_color in regions_dict:
		var region = load("res://Scenes/Region_Area.tscn").instantiate()
		region.region_name = regions_dict[region_color]
		region.set_name(region_color)
		get_node("Regions").add_child(region)
		
		var polygons = get_polygons(image, region_color, pixel_color_dict)
	
		for polygon in polygons:
			var region_collision = CollisionPolygon2D.new()
			var region_polygon = Polygon2D.new()
			
			region_collision.polygon = polygon
			region_polygon.polygon = polygon
			
			region.add_child(region_collision)
			region.add_child(region_polygon)
			
	mapImage.queue_free()

func get_pixel_color_dict(image):
	var pixel_color_dict = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color = "#" + str(image.get_pixel(int(x), int(y)).to_html(false))
			if pixel_color not in pixel_color_dict:
				pixel_color_dict[pixel_color] = []
			pixel_color_dict[pixel_color].append(Vector2(x,y))
	return pixel_color_dict

func get_polygons(image, region_color, pixel_color_dict):
	var targetImage = Image.create(image.get_size().x,image.get_size().y, false, Image.FORMAT_RGBA8)
	for value in pixel_color_dict[region_color]:
		targetImage.set_pixel(value.x,value.y, "#ffffff")
		
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(targetImage)
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(0,0), bitmap.get_size()), 0.1)
	return polygons

#Import JSON files and converts to lists or dictionary
func import_file(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " "))
	else:
		print("Failed to open file:", filepath)
		return null



func _on_popup_menu_id_pressed(id: PopupIds):
	 
	match id:
		PopupIds.Check_Nation:
			print("test2")
			print(prov_stats)
		PopupIds.set_prov_owner:
			print("test")
			# Get the hovered province name
			var HoveredProvince = Info_bank.HoveredProvince

			# Build the path to the province JSON file
			var prov_res = "res://Map_data/Provinces/" + HoveredProvince

			# Open the file in read mode first
			var prov_file = FileAccess.open(prov_res, FileAccess.READ)

			if prov_file == null:
				print("Failed to open file for reading:", prov_res)
				return

			# Read the file content and parse the JSON
			var json_text = prov_file.get_as_text()
			prov_file.close()  # Always close files when done

			# Parse JSON
			var json = JSON.new()
			var parse_result = json.parse(json_text)

			if parse_result != OK:
				print("Failed to parse JSON:", json.get_error_message())
				return

			var prov_stats = json.data

			# Debug prints
			print(Info_bank.HoveredNation)
			print(Info_bank.HoveredNationColour)
			print(Info_bank.ControlledNation)
			print(Info_bank.ControlledNationColour)

			# Modify the data
			prov_stats["countrie_color"] = Info_bank.ControlledNationColour
			prov_stats["province_controller"] = Info_bank.ControlledNation

			print(prov_stats)

			# Now reopen the file in WRITE mode to save the changes
			prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
			if prov_file == null:
				print("Failed to open file for writing:", prov_res)
				return

			# Write updated JSON to file
			prov_file.store_string(JSON.stringify(prov_stats, "\t"))  # "\t" = pretty print
			prov_file.close()

			print("Province JSON updated successfully.")

		PopupIds.Set_controlled_nation:
			
			
			Info_bank.ControlledNation = Info_bank.HoveredNation
			Info_bank.ControlledNationColour = Info_bank.HoveredNationColour
			
		PopupIds.Create_army:
			army_num += 1
			var army_base_data = {
				"army_tag" : "1"
				
			}
			
			var scene_to_instantiate = load("res://Map_data/armies/army.tscn")
			var new_scene = scene_to_instantiate.instantiate()
			add_child(new_scene)
			new_scene.position = _last_mouse_position
			Info_bank.name_of_army_file = "army" + str(army_num)
			var json_string = JSON.stringify(army_base_data, "\t")
			
			var army_file = FileAccess.open("res://Map_data/armies/" + "army" + str(army_num) + ".json", FileAccess.WRITE)
			army_file.store_string(json_string)
			army_file.close()
		PopupIds.army_menu_popup:
			print("army menu")
			var army_menu = load("res://Scenes/unit_menu.tscn")
			if Info_bank.army_menu_is_active == false:
				if Info_bank.something_selected == true:
					
					var new_scene = army_menu.instantiate()
					selected_army_menu = new_scene
					add_child(new_scene)
					new_scene.position = _last_mouse_position
					Info_bank.army_menu_is_active = true
					print(selected_army_menu)
			else:
				
				selected_army_menu.queue_free()
				Info_bank.army_menu_is_active = false


func _on_popup_menu_index_pressed(index: ) -> void:
	pass # Replace with function body.
