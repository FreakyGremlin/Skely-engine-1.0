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
var new_scene : Node
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
