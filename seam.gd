extends Node2D

var speed = 200
var direction = Vector2(1,0)
var screen_size = Vector2()
var window_size = Vector2(200,200)

var click_position = Vector2()
var target_position = Vector2()

var idle_timer = 0.0
var is_idling = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D

var is_dragging = false
var drag_offset = Vector2()


var last_mouse = Vector2()
var velocity = Vector2()

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("walk")
	area.input_event.connect(_on_area_input)
	

func _physics_process(delta: float) -> void:
	
	if is_dragging:
		animated_sprite.play("wrigle")
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed = 200
			animated_sprite.play("walk")
		return
	animated_sprite.play("walk")
	if Input.is_action_just_pressed("left_click"):
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "offset:y", -30.0, 0.15)
		tween.tween_property($AnimatedSprite2D, "offset:y", 0.0, 0.15)
		
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	print(window_position)
	window_position.x = clamp(window_position.x, 0, screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()

func maybe_idle():
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(1.0, 3.0)
		var r = randi() % 3
		if r == 0:
			animated_sprite.play("sit")
			speed = 0

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false


var usable = DisplayServer.screen_get_usable_rect()
var taskbar_y = usable.end.y
