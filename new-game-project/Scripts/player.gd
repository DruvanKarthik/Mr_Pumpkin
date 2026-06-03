extends CharacterBody2D

@export var speed = 100.0

func get_input():
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(input_direction * speed, velocity.y)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
