extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("You died.")
		Engine.time_scale = 0.5
		var collision_shape = body.get_node_or_null("CollisionShape2D")
		if collision_shape:
			collision_shape.queue_free()  # Disable player collision
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()  # Reset the scene
