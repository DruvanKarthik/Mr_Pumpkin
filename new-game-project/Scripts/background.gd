extends Node2D

var potion_scene = preload("res://Scenes/potion.tscn")

var score = 0

@onready var score_label = $ScoreLabel
@onready var player = $Player
@onready var health_label = $HealthLabel #adding the health label
@onready var lives_label = $LivesLabel #adding the lives label


func _ready():
	randomize()

	player.potion_collected.connect(_on_potion_collected)

	update_score()

func _on_timer_timeout():
	var new_potion = potion_scene.instantiate()

	var random_x = randf_range(
		0,
		get_viewport_rect().size.x
	)

	new_potion.position = Vector2(random_x, -50)

	add_child(new_potion)

func _on_potion_collected():
	score += 1
	update_score()

func update_score():
	score_label.text = "Score: " + str(score) # updating score
