extends Node2D
var region_name = ""
var _last_mouse_position
var selected_nation_name 
@onready var _pm = $PopupMenu
var poly_num = 0
var prov_stats = {
"prov_tag": "",
"name": "",
"countrie_color": "",
"province_controller": ""
}
var cur_ai = ""
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
var poly_num_for_array = 1
var bordered_array_string : Array[String] = []

var new_scene : Node
@onready var mapImage = $RegionMap

# Called when the node enters the scene tree for the first time.
func _ready():
	Info_bank.region_node_ref = $Regions
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
	
	Info_bank.main_scene_ref = $"."
	
	var nations_active_res = "res://Map_data/nations/nations_active.json"
	var nations_active_file = FileAccess.open(nations_active_res, FileAccess.READ)
	var nations_active_text = nations_active_file.get_as_text()
	nations_active_file.close()
	var nations_active_parse = JSON.parse_string(nations_active_text)
	var nations_active_array = nations_active_parse.get("nations_active")
	for id in nations_active_array:
		cur_ai = id
		if id == Info_bank.ControlledNation:
			ai_turn()
		else:
			var nation_res = "res://Map_data/nations/" + id + ".json"
			var nation_file = FileAccess.open(nation_res,FileAccess.READ)
			var nation_text = nation_file.get_as_text()
			nation_file.close()
			var nation_parse = JSON.parse_string(nation_text)
			nation_parse["controlled_armies"] = 0
			nation_parse["army_names"] = []
			var nation_string = JSON.stringify(nation_parse)
			nation_file = FileAccess.open(nation_res, FileAccess.WRITE)
			nation_file.store_string(nation_string)
			nation_file.close()
	
	
	
	
	
	var nat_ark_res = "res://Map_data/nations/nations_active.json"
	
	var nat_ark_list = {
		"nations_active" : ["AST", "FRI", "CLV", "LIG"]
	}
	
	
	var nat_ark_list_string = JSON.stringify(nat_ark_list)
	var nat_ark_file = FileAccess.open(nat_ark_res,FileAccess.WRITE)
	print(nat_ark_list)
	nat_ark_file.store_string(nat_ark_list_string)
	nat_ark_file.close()
	
	
	
	
func _input(event):
	if Input.is_action_just_pressed("test_imput_2"):
		if Info_bank.debug_mode_on == false:
			Info_bank.debug_mode_on = true
		else:
			Info_bank.debug_mode_on = false
	if Info_bank.debug_mode_on == true:
		if Input.is_action_just_pressed("click_left"):
			print(Info_bank.HoveredProvince)
			bordered_array_string.append(Info_bank.HoveredProvinceName + str(poly_num_for_array))
			poly_num_for_array += 1
		if Input.is_action_just_pressed("remove_id_in_array"):
			bordered_array_string.remove_at(0)
		if Input.is_action_just_pressed("commit_edits_to_file"):
			poly_num_for_array = 1
			var prov_res = "res://Map_data/Provinces/" + Info_bank.HoveredProvince
			var prov_file = FileAccess.open(prov_res, FileAccess.READ)
			var prov_text = prov_file.get_as_text()
			prov_file.close()
			var prov_parse = JSON.parse_string(prov_text)
			prov_parse["province_ids"] = bordered_array_string
			var prov_string = JSON.stringify(prov_parse, "\t")
			prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
			prov_file.store_string(prov_string)
			prov_file.close()
			for id in bordered_array_string:
				bordered_array_string.remove_at(0)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		var main_menu = load("res://Scenes/main_menu.tscn")
		_last_mouse_position = get_global_mouse_position()
		Info_bank.last_mouse_position = _last_mouse_position
		Info_bank.selected_prov = Info_bank.HoveredProvince
		Info_bank.selected_prov_name = Info_bank.HoveredProvinceName
		if Info_bank.menu_is_active == false:
			Info_bank.new_scene = main_menu.instantiate()
			selected_army_menu = Info_bank.new_scene
			add_child(Info_bank.new_scene)
			Info_bank.main_menu = Info_bank.new_scene
			Info_bank.new_scene.position = _last_mouse_position
			Info_bank.menu_is_active = true
		else:
			if Info_bank.new_scene != null:
				Info_bank.new_scene.queue_free()
				Info_bank.new_scene = null
				Info_bank.menu_is_active = false
			Info_bank.menu_is_active = false
			
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
	print(region_name)
	for region_color in regions_dict:
		poly_num = 0
		
		
		var region = load("res://Scenes/Region_Area.tscn").instantiate()
		region.region_name = regions_dict[region_color]
		Info_bank.region_name = region.region_name
		region.set_name(region_color)
		get_node("Regions").add_child(region)
		var polygons = get_polygons(image, region_color, pixel_color_dict)
		print(region.region_name + "region")
		
		
		
		var prov_res = "res://Map_data/Provinces/" + Info_bank.region_name + ".json"
		
		var prov_file = FileAccess.open(prov_res, FileAccess.READ)
		if prov_file:
			print(prov_res)
			
			var prov_text = prov_file.get_as_text()
			print(prov_text)
			prov_file.close()
			var prov_parse = JSON.parse_string(prov_text)
			prov_parse["has_army"] = false
			prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
			var prov_string = JSON.stringify(prov_parse, "\t")
			prov_file.store_string(prov_string)
			prov_file.close()
		
		
		
		
		for polygon in polygons:
			
			poly_num += 1
			var region_collision = CollisionPolygon2D.new()
			var region_polygon = Polygon2D.new()
			region_polygon.name = region.region_name + str(poly_num)
			
			
			
			region_collision.polygon = polygon
			region_polygon.polygon = polygon
			
			region.add_child(region_collision)
			region.add_child(region_polygon)
			
	mapImage.queue_free()

func get_pixel_color_dict(image):
	var pixel_color_dict = {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel_color = "#" + str(image.get_pixel(x, y).to_html(false))
			if pixel_color not in pixel_color_dict:
				pixel_color_dict[pixel_color] = []
			pixel_color_dict[pixel_color].append(Vector2(x, y))
	return pixel_color_dict


func get_polygons(image, region_color, pixel_color_dict):
	var target_image = Image.create(image.get_size().x, image.get_size().y, false, Image.FORMAT_RGBA8)
	target_image.fill(Color(0, 0, 0, 0))  # Ensure transparent background
	
	for value in pixel_color_dict[region_color]:
		target_image.set_pixel(value.x, value.y, Color(1, 1, 1, 1))  # Opaque white

	# Important: Lock image if needed (depending on version)
	# target_image.lock()

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(target_image)

	var rect = Rect2(Vector2(0, 0), bitmap.get_size())
	var polygons = bitmap.opaque_to_polygons(rect, 0.0)  # No simplification
	
	return polygons

#Import JSON files and converts to lists or dictionary
func import_file(filepath):
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file != null:
		return JSON.parse_string(file.get_as_text().replace("_", " "))
	else:
		print("Failed to open file:", filepath)
		return null



func ai_turn():
	var nations_active_res = "res://Map_data/nations/nations_active.json"
	var nations_active_file = FileAccess.open(nations_active_res, FileAccess.READ)
	var nations_active_text = nations_active_file.get_as_text()
	nations_active_file.close()
	var nations_active_parse = JSON.parse_string(nations_active_text)
	var nations_active_array = nations_active_parse.get("nations_active")
	var controlled_armies_num = 0
	for id in nations_active_array:
		cur_ai = id
		if id == Info_bank.ControlledNation:
			ai_turn()
		else:
			var nation_res = "res://Map_data/nations/" + id + ".json"
			var nation_file = FileAccess.open(nation_res,FileAccess.READ)
			var nation_text = nation_file.get_as_text()
			nation_file.close()
			var nation_parse = JSON.parse_string(nation_text)
			controlled_armies_num = nation_parse.get("controlled_armies")
			if controlled_armies_num > 0:
				move_army()
				
			else:
				ai_creates_army()
				
		

	
func ai_creates_army():
	print("army in making")
	var nations_active_res = "res://Map_data/nations/nations_active.json"
	var nations_active_file = FileAccess.open(nations_active_res, FileAccess.READ)
	var nations_active_text = nations_active_file.get_as_text()
	nations_active_file.close()
	var nations_active_parse = JSON.parse_string(nations_active_text)
	var nations_active_array = nations_active_parse.get("nations_active")
	var nation_res = "res://Map_data/nations/" + cur_ai + ".json"
	var nation_file = FileAccess.open(nation_res,FileAccess.READ)
	var nation_text = nation_file.get_as_text()
	nation_file.close()
	var nation_parse = JSON.parse_string(nation_text)
	nation_parse["controlled_armies"] += 1
	var army_name_array = nation_parse.get("army_names")
	var nation_capital = nation_parse.get("capital_prov")
	print(nation_res + "monitor")
	var prov_res = "res://Map_data/Provinces/" + nation_capital + ".json"
	Info_bank.cur_ai_make_army = nation_capital
	var prov_file = FileAccess.open(prov_res, FileAccess.READ)
	print(prov_res + "monitor text ")
	var prov_text = prov_file.get_as_text()
	
	prov_file.close()
	var prov_parse = JSON.parse_string(prov_text)
	var tile_has_army = prov_parse.get("has_army")
	print(str(tile_has_army) + "tilehasarmy" )
	if tile_has_army == false:
		prov_parse["has_army"] = true
		var prov_string = JSON.stringify(prov_parse, "\t")
		print(prov_parse)
		
		var canvas_layer: CanvasLayer = null
		Info_bank.army_num += 1
		Info_bank.name_of_current_army_file = "army" + str(Info_bank.army_num)
		var army_base_data = {
			"army_tag" : "1",
			"infantry_num" : 0,
			"tile_located_on" : nation_capital + ".json",
			"army_controller" : cur_ai
			
		}
		army_name_array.append(Info_bank.name_of_current_army_file)
		var nat_string = JSON.stringify(nation_parse, "\t")
		nation_file = FileAccess.open(nation_res, FileAccess.WRITE)
		nation_file.store_string(nat_string)
		nation_file.close()
		
		
		
		Info_bank.name_of_army_file = "army" + str(Info_bank.army_num)
		var json_string = JSON.stringify(army_base_data, "\t")
		var army_file = FileAccess.open("res://Map_data/armies/" + "army" + str(Info_bank.army_num) + ".json", FileAccess.WRITE)
		army_file.store_string(json_string)
		army_file.close()
		var scene_to_instantiate = load("res://Map_data/armies/enemy.tscn")
		var new_scene = scene_to_instantiate.instantiate()
		
		new_scene.name = "ai_unit" + cur_ai
		Info_bank.armies_active_names.append(new_scene.name)
		print(Info_bank.armies_active_names)
		
		prov_file = FileAccess.open(prov_res, FileAccess.WRITE)
		prov_file.store_string(prov_string)
		prov_file.close()
		get_tree().get_root().get_child(1).add_child(new_scene)
	Info_bank.is_player_active = true

func move_army():
	var scene_root : Node = null
	for Node in $".".get_children():
		if Node.name == "ai_unit" + cur_ai:
			scene_root = Node
	
	
	
	print("moving army")
	var nation_res = "res://Map_data/nations/" + cur_ai + ".json"
	var nation_file = FileAccess.open(nation_res,FileAccess.READ)
	var nation_text = nation_file.get_as_text()
	nation_file.close()
	var nation_parse = JSON.parse_string(nation_text)
	var army_name_array = nation_parse.get("army_names")
	
	for id in army_name_array:
		var army_res = "res://Map_data/armies/" + id + ".json"
		var army_file = FileAccess.open(army_res, FileAccess.READ)
		var army_text = army_file.get_as_text()
		army_file.close()
		var army_parse = JSON.parse_string(army_text)
		var army_location = army_parse.get("tile_located_on")
		var army_controller = army_parse.get("army_controller")
		
		var tile_res = "res://Map_data/Provinces/" + army_location
		var tile_file = FileAccess.open(tile_res, FileAccess.READ)
		var tile_text = tile_file.get_as_text()
		tile_file.close()
		var tile_parse = JSON.parse_string(tile_text)
		var bordered_tiles = tile_parse.get("bordered_provs")
		print(str(bordered_tiles) + str(cur_ai) + " tiles" + str(army_location))
		var tile_moving_to = bordered_tiles.pick_random()
		
		var prov_res = "res://Map_data/Provinces/" + tile_moving_to + ".json"
		var prov_file = FileAccess.open(prov_res, FileAccess.READ)
		var prov_text = prov_file.get_as_text()
		tile_file.close()
		var prov_parse = JSON.parse_string(prov_text)
		var prov_marker = prov_parse.get("unit_marker")
		var prov_tile_controller = prov_parse.get("province_controller")
		if prov_tile_controller != army_controller:
			pass
		else:
			scene_root.position = Vector2(prov_marker[0], prov_marker[1])
			
			army_parse["tile_located_on"] = tile_moving_to + ".json"
			
			var army_string = JSON.stringify(army_parse, "\t")
			army_file = FileAccess.open(army_res, FileAccess.WRITE)
			army_file.store_string(army_string)
			army_file.close()
			
			
	Info_bank.is_player_active = true
