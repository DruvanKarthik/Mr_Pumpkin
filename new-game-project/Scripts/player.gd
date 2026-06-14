extends CharacterBody2D

signal potion_collected(potion_type)
signal lose_life
signal shield_ended
signal speed_ended
signal size_ended

@export var speed = 200.0
const BASE_SPEED = 200.0
const SHIELD_DURATION = 10.0
const SPEED_BOOST_DURATION = 10.0
const SIZE_BOOST_DURATION = 10.0

var has_brown = false
var is_shielded = false
var is_speed_boosted = false
var is_size_boosted = false

var shield_timer = 0.0
var speed_boost_timer = 0.0
var size_boost_timer = 0.0

var shield_visual: Polygon2D

func _ready():
	_create_shield_visual()

func _create_shield_visual():
	shield_visual = Polygon2D.new()
	var points = PackedVector2Array()
	var num_points = 32
	var width = 22.0
	var height = 28.0
	for i in range(num_points):
		var angle = (2 * PI * i) / num_points
		points.append(Vector2(cos(angle) * width, sin(angle) * height))
	shield_visual.polygon = points
	shield_visual.color = Color(1.0, 0.5, 0.0, 0.28)
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

	if is_speed_boosted:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			is_speed_boosted = false
			speed = BASE_SPEED
			emit_signal("speed_ended")

	if is_size_boosted:
		size_boost_timer -= delta
		if size_boost_timer <= 0:
			is_size_boosted = false
			scale = Vector2(1.0, 1.0)
			has_brown = false
			emit_signal("size_ended")

func _apply_boundary():
	var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.is_in_group("potions"):
		return
	if not is_instance_valid(area):
		return
	var ptype = area.get("potion_type")
	if ptype != null:
		emit_signal("potion_collected", ptype)
	area.remove_from_group("potions")
	area.queue_free()

func apply_potion(potion_type: String):
	match potion_type:
		"brown":
			has_brown = true
			is_size_boosted = true
			size_boost_timer = SIZE_BOOST_DURATION
			scale = Vector2(1.5, 1.5)
		"dark_green":
			is_speed_boosted = true
			speed_boost_timer = SPEED_BOOST_DURATION
			speed = BASE_SPEED + 100.0
		"orange":
			is_shielded = true
			shield_timer = SHIELD_DURATION
			shield_visual.visible = true
