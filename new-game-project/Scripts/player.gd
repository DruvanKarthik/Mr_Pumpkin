extends CharacterBody2D

signal potion_collected(potion_type)
signal lose_life
signal shield_ended

@export var speed = 200.0
var has_brown = false
var is_shielded = false
var shield_timer = 0.0
const SHIELD_DURATION = 10.0
var shield_visual: ColorRect

func _ready():
	_create_shield_visual()

func _create_shield_visual():
	shield_visual = ColorRect.new()
	shield_visual.color = Color(0.3, 0.7, 1.0, 0.25)
	shield_visual.size = Vector2(80, 80)
	shield_visual.position = Vector2(-40, -40)
	shield_visual.visible = false
	add_child(shield_visual)

func get_input():
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity = Vector2(input_direction * speed, 0)

func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()
	_apply_boundary()

	if is_shielded:
		shield_timer -= delta
		if shield_timer <= 0:
			is_shielded = false
			shield_visual.visible = false
			emit_signal("shield_ended")

func _apply_boundary():
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("=== COLLISION DETECTED ===")
	print("Area name: ", area.name)
	print("Area groups: ", area.get_groups())
	print("Potion type: ", area.get("potion_type"))
	if area.is_in_group("potions"):
		var ptype = area.get("potion_type")
		if ptype != null:
			emit_signal("potion_collected", ptype)
		area.queue_free()

func apply_potion(potion_type: String):
	match potion_type:
		"brown":
			has_brown = true
			scale = Vector2(1.5, 1.5)
			shield_visual.size = Vector2(110, 110)
			shield_visual.position = Vector2(-55, -55)
		"dark_green":
			speed += 100.0
		"orange":
			is_shielded = true
			shield_timer = SHIELD_DURATION
			shield_visual.visible = true
