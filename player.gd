extends Node3D


const LOOK_MAX: float = 20.0
const POS_MAX: float = 108.0
const POS_TO_LOOK_RATIO: float = LOOK_MAX / POS_MAX
const DRIFT_RESET_SPEED: float = 20.0


var speed: float = 1.0
var sensitivity: float = 0.01


@onready var shooters: Array[Node3D] = [
	$model_anchor/spaceship/fire_0,
	$model_anchor/spaceship/fire_1
]

@onready var game: Node3D = $".."
@onready var model_anchor: Node3D = $model_anchor


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


const BULLET = preload("res://bullet.tscn")
var shoot_order: int = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Input.set_deferred("mouse_mode", Input.MOUSE_MODE_CAPTURED)


var drift: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		fire_bullet()
	
	var mouse_delta: Vector2 = Input.get_last_mouse_velocity()
	drift += mouse_delta * sensitivity
	
	drift.x = clamp(drift.x, -LOOK_MAX, LOOK_MAX)
	drift.y = clamp(drift.y, -LOOK_MAX, LOOK_MAX)
	
	var top_left := Vector2(-LOOK_MAX, LOOK_MAX)
	var bottom_right := Vector2(LOOK_MAX, -LOOK_MAX)
	
	var vec2_pos := Vector2(position.x, position.y)
	var vec2_look := vec2_pos * POS_TO_LOOK_RATIO
	
	var to_top_left: Vector2 = abs(vec2_look - top_left)
	var to_bottom_right: Vector2 = abs(bottom_right - vec2_look)
	
	#drift.x = clamp(drift.x, to_top_left.x, -to_bottom_right.x)
	#drift.y = clamp(drift.y, -to_bottom_right.y, to_top_left.y)
	
	model_anchor.rotation_degrees.y = drift.x
	model_anchor.rotation_degrees.x = drift.y
	
	if mouse_delta.length() < 0.001:
		drift = drift.move_toward(Vector2.ZERO, delta * DRIFT_RESET_SPEED)
	
	fire_cooldown -= delta


@onready var go_here: Node3D = $model_anchor/go_here


func _physics_process(_delta: float) -> void:
	var old_pos := position
	position = go_here.global_position
	position.x = clamp(position.x, -POS_MAX, POS_MAX)
	position.y = clamp(position.y, -POS_MAX, POS_MAX)
	var went := position.z - old_pos.z
	position.z = old_pos.z + went * speed


var fire_cooldown: float = .0


func fire_bullet() -> void:
	if fire_cooldown > 0:
		return
	
	var bullet = BULLET.instantiate()
	var shooter: Node3D = shooters[shoot_order % shooters.size()]
	var middle := shooter.global_position
	middle.x = global_position.x
	
	bullet.player_speed = speed
	bullet.rotation = model_anchor.rotation
	game.add_child(bullet)
	bullet.global_position = shooter.global_position
	
	shoot_order += 1
	fire_cooldown = 0.1
