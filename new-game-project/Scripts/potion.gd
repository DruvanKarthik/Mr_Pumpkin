extends Area2D
var speed = 300

func _process(delta: float) -> void:
	position.y += delta*speed 
