extends Node2D

var potion_scenes = {
	"black":      preload("res://Scenes/potion_black.tscn"),
	"green":      preload("res://Scenes/potion_green.tscn"),
	"purple":     preload("res://Scenes/potion_purple.tscn"),
	"light_blue": preload("res://Scenes/potion_light_blue.tscn"),
	"brown":      preload("res://Scenes/potion_brown.tscn"),
	"dark_green": preload("res://Scenes/potion_dark_green.tscn"),
	"red":        preload("res://Scenes/potion_red.tscn"),
	"orange":     preload("res://Scenes/potion_orange.tscn")
}

var potion_types = ["black","green","purple","light_blue","brown","dark_green","red","orange"]

var score = 0
var lives = 5
var shield_countdown = 0.0
var shield_active = false
var speed_countdown = 0.0
var speed_active = false
var size_countdown = 0.0
var size_active = false

@onready var score_label  = $CanvasLayer/ScoreLabel
@onready var lives_label  = $CanvasLayer/LivesLabel
@onready var status_label = $CanvasLayer/StatusLabel
@onready var player       = $Player
@onready var spawn_timer  = $Timer

func _ready():
	randomize()

	if player == null:
		print("ERROR: Player not found!")
		return
	if score_label == null:
		print("ERROR: ScoreLabel not found!")
		return
	if lives_label == null:
		print("ERROR: LivesLabel not found!")
		return
	if status_label == null:
		print("ERROR: StatusLabel not found!")
		return

	player.potion_collected.connect(_on_potion_collected)
	player.lose_life.connect(_on_lose_life)
	player.shield_ended.connect(_on_shield_ended)
	player.speed_ended.connect(_on_speed_ended)
	player.size_ended.connect(_on_size_ended)

	status_label.visible = false
	update_score()
	update_lives()

	spawn_timer.wait_time = randf_range(1.5, 3.0)
	spawn_timer.start()

func _process(delta):
	if shield_active:
		shield_countdown -= delta
		if shield_countdown <= 0:
			shield_countdown = 0
			shield_active = false

	if speed_active:
		speed_countdown -= delta
		if speed_countdown <= 0:
			speed_countdown = 0
			speed_active = false

	if size_active:
		size_countdown -= delta
		if size_countdown <= 0:
			size_countdown = 0
			size_active = false

	_update_status()

func _update_status():
	var lines = []
	if shield_active and shield_countdown > 0:
		lines.append("🛡 Shield: " + str(snapped(shield_countdown, 0.1)) + "s")
	if speed_active and speed_countdown > 0:
		lines.append("💨 Speed: " + str(snapped(speed_countdown, 0.1)) + "s")
	if size_active and size_countdown > 0:
		lines.append("🟫 Size: " + str(snapped(size_countdown, 0.1)) + "s")

	if lines.size() > 0:
		status_label.visible = true
		status_label.text = "\n".join(lines)
	else:
		status_label.visible = false

func _on_timer_timeout():
	var random_type = potion_types[randi() % potion_types.size()]
	var new_potion = potion_scenes[random_type].instantiate()
	add_child(new_potion)

	var screen = get_viewport_rect().size
	var margin = 40
	new_potion.position = Vector2(
		randf_range(margin, screen.x - margin),
		randf_range(-100, -30)
	)

	spawn_timer.wait_time = randf_range(1.5, 3.0)
	spawn_timer.start()

func _on_potion_collected(potion_type: String):
	player.apply_potion(potion_type)

	match potion_type:
		"black":
			score += 1
		"green":
			score += 10
		"purple":
			lives += 1
			update_lives()
		"light_blue":
			if not player.is_shielded:
				lives -= 1
				update_lives()
		"brown":
			score += 5
			size_active = true
			size_countdown = 10.0
		"dark_green":
			speed_active = true
			speed_countdown = 10.0
		"red":
			if player.has_brown:
				score += 10
			elif not player.is_shielded:
				lives -= 1
				update_lives()
		"orange":
			shield_active = true
			shield_countdown = 10.0

	update_score()

	if lives <= 0:
		game_over()

func _on_lose_life():
	lives -= 1
	update_lives()
	if lives <= 0:
		game_over()

func _on_shield_ended():
	shield_active = false

func _on_speed_ended():
	speed_active = false

func _on_size_ended():
	size_active = false

func update_score():
	score_label.text = "Score: " + str(score)

func update_lives():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️ "
	lives_label.text = hearts

func game_over():
	get_tree().paused = true
	print("Game Over!")
