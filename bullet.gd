extends Node3D


const SPEED: float = 3.0

var player_speed: float = 1.0
var travelled: float = .0


func _physics_process(_delta: float) -> void:
	if travelled > 50.0:
		queue_free()
		return
	
	var direction := Vector3.FORWARD
	if rotation.length() > .0:
		direction = direction.rotated(rotation.normalized(), rotation.length())
	var old_pos = position
	position += direction * (player_speed + SPEED)
	travelled += (position - old_pos).length()
