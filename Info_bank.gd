extends Node
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
var new_scene: Node = null
@onready var root_scene_node : Node = $"."
var name_of_current_army_file = ""
var army_num = 0
var region_name = ""
