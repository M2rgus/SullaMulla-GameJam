extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea  # Reference to the Attack Area

var is_attacking = false

func _ready():
	add_to_group("player")  # Add player to "player" group for DamageZone detection
	attack_area.connect("area_entered", Callable(self, "_on_attack_area_entered"))
	attack_area.add_to_group("player_attack")  # Add AttackArea to "player_attack" group

func _physics_process(delta: float) -> void:
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# Handle attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# Movement direction
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	# Animation logic
	if not is_attacking:  # Only update movement animations if not attacking
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("idle")
			else:
				animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("jump")

	# Handle movement
	if not is_attacking:  # Prevent movement during attack
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)  # Slow down during attack

	move_and_slide()

func attack():
	is_attacking = true
	animated_sprite_2d.play("attack")
	await animated_sprite_2d.animation_finished
	is_attacking = false

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		if area.has_method("on_hit"):
			area.on_hit()
