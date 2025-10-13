extends Camera2D
@onready var camera_ref = $"."
@export var zoom_speed: float = 0.1 # How much the zoom changes per scroll
@export var min_zoom: Vector2 = Vector2(-1, -1) # Minimum zoom level
@export var max_zoom: Vector2 = Vector2(2.0, 2.0) # Maximum zoom level

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		zoom -= Vector2(zoom_speed, zoom_speed)
		zoom = zoom.clamp(min_zoom, max_zoom) # Clamp zoom to limits
	elif event.is_action_pressed("zoom_out"):
		zoom += Vector2(zoom_speed, zoom_speed)
		zoom = zoom.clamp(min_zoom, max_zoom) # Clamp zoom to limits
	
func _process(delta):
	if Input.is_action_pressed("left"):
		camera_ref.position.x -= 10
		print(camera_ref.position.x)
	if Input.is_action_pressed("right"):
		camera_ref.position.x += 10
		print(camera_ref.position.x)
	if Input.is_action_pressed("up"):
		camera_ref.position.y -= 10
		print(camera_ref.position.y)
	if Input.is_action_pressed("down"):
		camera_ref.position.y += 10
		print(camera_ref.position.y)
