extends Node3D


const DISTANT_STAR = preload("res://assets/flair/distant_star.tscn")


func _ready() -> void:
	for n in range(300):
		var star: Sprite3D = DISTANT_STAR.instantiate()
		
		var alpha: float
		if n < 150:
			alpha = randf_range(120, 180)
		else:
			alpha = randf_range(0, 60)
		
		var dist: float = randf_range(3000.0, 4000.0)
		
		var plane := (dist * Vector2.RIGHT).rotated(deg_to_rad(alpha))
		
		star.position.x = -plane.x
		star.position.z = -plane.y
		star.position.y = randf_range(-6000.0, 3000.0)
		
		add_child(star)
