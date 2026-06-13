extends Node2D

# preload all 8 potion scenes
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

@onready var score_label = $ScoreLabel
@onready var lives_label = $LivesLabel
@onready var shield_label = $ShieldLabel
@onready var player = $Player

func _ready():
	randomize()
	player.potion_collected.connect(_on_potion_collected)
	player.lose_life.connect(_on_lose_life)
	update_score()
	update_lives()

func _on_timer_timeout():
	var random_type = potion_types[randi() % potion_types.size()]
	var new_potion = potion_scenes[random_type].instantiate()
	var random_x = randf_range(0, get_viewport_rect().size.x)
	new_potion.position = Vector2(random_x, -50)
	add_child(new_potion)

func _on_potion_collected(potion_type: String):
	player.apply_potion(potion_type)

	match potion_type:
		"black":
			score += 1
			show_message("+1 Score", Color(1, 1, 1))
		"green":
			score += 10
			show_message("+10 Score!", Color(0.4, 1.0, 0.4))
		"purple":
			lives += 1
			update_lives()
			show_message("+1 Life ❤️", Color(0.8, 0.0, 0.8))
		"light_blue":
			if not player.is_shielded:
				lives -= 1
				update_lives()
				show_message("Ouch! -1 Life 💧", Color(0.5, 0.8, 1.0))
		"brown":
			score += 5
			show_message("+5 Score! Size Up!", Color(0.6, 0.3, 0.1))
		"dark_green":
			show_message("Speed Boost! 💨", Color(0.0, 0.8, 0.0))
		"red":
			if player.has_brown:
				score += 10
				show_message("+10 Red Bonus!", Color(1.0, 0.0, 0.0))
			elif not player.is_shielded:
				lives -= 1
				update_lives()
				show_message("Danger! -1 Life!", Color(1.0, 0.0, 0.0))
		"orange":
			show_message("Shielded for 10s! 🛡", Color(1.0, 0.5, 0.0))

	update_score()
	if lives <= 0:
		game_over()

func _on_lose_life():
	lives -= 1
	update_lives()
	if lives <= 0:
		game_over()

func update_score():
	score_label.text = "Score: " + str(score)

func update_lives():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️ "
	lives_label.text = hearts

func show_message(text: String, color: Color) -> void:
	shield_label.text = text
	shield_label.modulate = color
	await get_tree().create_timer(1.5).timeout
	shield_label.text = ""

func game_over():
	print("Game Over!")
	get_tree().paused = true
