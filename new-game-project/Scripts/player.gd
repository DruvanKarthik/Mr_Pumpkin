extends CharacterBody2D

signal potion_collected(potion_type)

@export var speed = 100.0
var has_brown = false
var is_shielded = false
var shield_timer = 0.0
const SHIELD_DURATION = 10.0

func get_input():
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(input_direction * speed, 0)

func _physics_process(delta):
	get_input()
	move_and_slide()
	if is_shielded:
		shield_timer -= delta
		if shield_timer <= 0:
			is_shielded = false
			print("Shield ended")

func _on_area_2d_area_entered(area):
	if area.is_in_group("potions"):
		var potion_type = area.potion_type
		emit_signal("potion_collected", potion_type)
		area.queue_free()

func apply_potion(potion_type: String):
	match potion_type:
		"black":
			pass  # just score, handled in background.gd
		"green":
			pass  # score bonus, handled in background.gd
		"purple":
			pass  # life, handled in background.gd
		"light_blue":
			if not is_shielded:
				emit_signal("lose_life")
		"brown":
			has_brown = true
			scale = Vector2(1.5, 1.5)
		"dark_green":
			speed += 100.0
			print("Speed is now: ", speed)
		"red":
			if not has_brown and not is_shielded:
				emit_signal("lose_life")
		"orange":
			is_shielded = true
			shield_timer = SHIELD_DURATION
			print("Shield active!")

signal lose_life
