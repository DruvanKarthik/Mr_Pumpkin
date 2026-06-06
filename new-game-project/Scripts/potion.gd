extends Area2D

@export var speed = 150.0

func _ready():
	add_to_group("potions")

func _process(delta):
	position.y += speed * delta

	if position.y > get_viewport_rect().size.y + 50:
		queue_free() # freeing teh que once the potion was collided with player
