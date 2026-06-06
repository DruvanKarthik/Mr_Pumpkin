extends CharacterBody2D

signal potion_collected

@export var speed = 100.0

func get_input():
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(input_direction * speed, 0)

func _physics_process(delta):
	get_input()
	move_and_slide()

func _on_area_2d_area_entered(area):
	if area.is_in_group("potions"):
		area.queue_free()
		emit_signal("potion_collected") # collision detection for collecting score for the potions
