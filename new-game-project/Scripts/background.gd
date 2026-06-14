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

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var lives_label = $CanvasLayer/LivesLabel
@onready var shield_timer_label = $CanvasLayer/ShieldTimerLabel
@onready var player = $Player
@onready var spawn_timer = $Timer

func _ready():
	randomize()

	if player == null:
		print("ERROR: Player node not found!")
		return
	if score_label == null:
		print("ERROR: ScoreLabel not found!")
		return
	if lives_label == null:
		print("ERROR: LivesLabel not found!")
		return
	if shield_timer_label == null:
		print("ERROR: ShieldTimerLabel not found!")
		return

	player.potion_collected.connect(_on_potion_collected)
	player.lose_life.connect(_on_lose_life)
	player.shield_ended.connect(_on_shield_ended)

	shield_timer_label.visible = false
	update_score()
	update_lives()

	# set first spawn time
	spawn_timer.wait_time = randf_range(1.5, 3.0)
	spawn_timer.start()

func _process(delta):
	if shield_active:
		shield_countdown -= delta
		if shield_countdown <= 0:
			shield_countdown = 0
			shield_active = false
			shield_timer_label.visible = false
		else:
			shield_timer_label.text = "🛡 Shield: " + str(snapped(shield_countdown, 0.1)) + "s"

func _on_timer_timeout():
	# pick random potion type
	var random_type = potion_types[randi() % potion_types.size()]
	var new_potion = potion_scenes[random_type].instantiate()

	# add to scene first so viewport is accessible
	add_child(new_potion)

	# get screen size
	var screen = get_viewport_rect().size
	var margin = 40

	# spawn at random x across full screen width, random y above screen
	new_potion.position = Vector2(
		randf_range(margin, screen.x - margin),
		randf_range(-100, -30)
	)

	# randomize next spawn gap so potions never bunch up
	spawn_timer.wait_time = randf_range(1.5, 3.0)
	spawn_timer.start()

func _on_potion_collected(potion_type: String):
	print("=== POTION COLLECTED: ", potion_type, " ===")
	print("Lives before: ", lives)
	print("Is shielded: ", player.is_shielded)
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
			print("Light blue logic hit!")
			if not player.is_shielded:
				lives -= 1
				print("Lives after: ", lives)
				update_lives()
			else:
				print("Player is shielded, no life lost")
		"brown":
			score += 5
		"dark_green":
			pass
		"red":
			if player.has_brown:
				score += 10
			elif not player.is_shielded:
				lives -= 1
				update_lives()
		"orange":
			print("Orange logic hit! Activating shield timer")
			shield_active = true
			shield_countdown = 10.0
			shield_timer_label.visible = true
			shield_timer_label.text = "🛡 Shield: 10s"

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
	shield_timer_label.visible = false

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
