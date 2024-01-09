extends CharacterBody3D

@export_subgroup("Components")
@export var view: Node3D
@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7

const JUMP_VELOCITY = 8.5
const BUBBLE_ANTI_GRAVITY = 2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var bubble_velocity = BUBBLE_ANTI_GRAVITY

var movement_velocity: Vector3
var rotation_direction: float

var inside_bubble:float = false
var prev_shape_radius: float
var prev_shape_height: float
var prev_decal_scale: Vector3

func _ready():
	prev_decal_scale = %decal.scale
	prev_shape_radius = %collision_shape.shape.radius
	prev_shape_height = %collision_shape.shape.height
	%bubble_sprite.visible = false

func enter_bubble(bubble):
	inside_bubble = true
	position = bubble.global_position # + Vector3(0, 1, 0) * bubble.size
	%bubble_sprite.visible = true
	# %bubble_sprite.scale = Vector3(bubble.size, bubble.size, bubble.size)
	%decal.scale *= bubble.size
	%collision_shape.shape.radius = bubble.size
	if bubble.size >= Global.BUBBLE_ENTER_SIZE:
		%bubble_sprite.scale = Vector3(bubble.size, bubble.size, bubble.size)
	else:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(%bubble_sprite, "scale", Vector3(bubble.size, bubble.size, bubble.size), 0.6)

func leave_bubble():
	Global.splash(get_parent(), position, %bubble_sprite.scale)
	inside_bubble = false
	%bubble_sprite.visible = false
	%decal.scale = prev_decal_scale
	%collision_shape.shape.radius = prev_shape_radius
	%collision_shape.shape.height = prev_shape_height
	%model.rotation.x = 0
	%model.rotation.z = 0

func _physics_process(delta):
	handle_controls(delta)
	
	# Movement23
	var applied_velocity: Vector3
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	if inside_bubble:
		applied_velocity.y = bubble_velocity
	elif not is_on_floor(): 
		applied_velocity.y -= gravity / 2

	velocity = applied_velocity
	move_and_slide()
	
	if inside_bubble and get_slide_collision_count():
		var collision = get_slide_collision(0)
		var layer = collision.get_collider().collision_layer
		if layer & Global.THORN_LAYER_BIT == Global.THORN_LAYER_BIT:
			leave_bubble()
	
	# Rotation

	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
			
	var floor_normal = get_floor_normal()
	# rotation.z = lerp_angle(rotation.z, floor_normal.z, delta * 10)
	# rotation.x = lerp_angle(rotation.x, floor_normal.x, delta * 10)

	# transform.basis = Basis.from_euler(floor_normal)
	if inside_bubble:
		%model.position.y = cos(position.x + position.z + Time.get_ticks_msec()/500.0) * 0.3
		%model.rotation.x += 0.5 * delta
		%model.rotation.z += 0.1 * delta
		# pass
	else:
		rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 20)
	# look_at(global_transform.origin, floor_normal)

func handle_controls(delta):
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	movement_velocity = input * movement_speed * delta
	if inside_bubble:
		%particles.emitting = false
		%particles2.emitting = true
		movement_velocity *= 0.5
		if Input.is_action_pressed("running"):
			bubble_velocity = BUBBLE_ANTI_GRAVITY * 4
		else:
			bubble_velocity = BUBBLE_ANTI_GRAVITY
	else:
		%particles2.emitting = false
		if Input.is_action_pressed("running"):
			if movement_velocity.length_squared() > 0:
				%particles.emitting = true
			movement_velocity *= 3
		else:
			%particles.emitting = false
	
