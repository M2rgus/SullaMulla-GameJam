extends Node2D

const SPEED = 60.0
var direction = 1
var is_dead = false

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var killzone: Area2D = $KillZone  # Detects player attack

func _ready():
	add_to_group("enemies")  # Add to "enemies" group
	killzone.connect("area_entered", Callable(self, "_on_killzone_area_entered"))

func on_hit():
	if is_dead:
		return
	is_dead = true
	print("Slime hit!")
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()

func _on_killzone_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		on_hit()

func _process(delta: float) -> void:
	if is_dead:
		return

	# Flip direction based on raycast collisions
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	# Move the enemy
	position.x += direction * SPEED * delta
