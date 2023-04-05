class_name Player
extends Actor

@export var acceleration: float
@export var ground_friction: float
@export var air_friction: float

var can_double_jump := true


func _physics_process(delta: float) -> void:
	# Status
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		can_double_jump = true

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		
		# Ground jump
		if is_on_floor():
			velocity.y = -abs(jump_velocity)
		else:
			if can_double_jump:
				velocity.y = -abs(jump_velocity)
				can_double_jump = false

	# Jump cancel
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.25

	# Input direction
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, direction * max_speed, acceleration)
		if direction > 0:
			$Sprite2D.flip_h = true
		elif direction < 0:
			$Sprite2D.flip_h = false
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, ground_friction)
		else:
			velocity.x = lerp(velocity.x, 0.0, air_friction)

	# Animation
	if is_on_floor():
		if direction:
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.play("idle")
	else:
		$AnimationPlayer.play("aerial")

	move_and_slide()


func die() -> void:
	get_tree().reload_current_scene()


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
	velocity.y = -abs(jump_velocity)
