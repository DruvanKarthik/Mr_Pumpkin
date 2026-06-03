extends Node2D

var potion = preload("res://Scenes/potion.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	var random_x = randf_range(0, get_viewport_rect().size.x)
	var new_potion = potion.instantiate()        # 1. Create the instance
	new_potion.position = Vector2(random_x, -200) # 2. Set its position
	add_child(new_potion)                         # 3. Add it to the scene
