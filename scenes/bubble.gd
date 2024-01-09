@tool

extends RigidBody3D
class_name Bubble

@export_subgroup("Properties")
@export var size = 1.0

var enter_bubble_strength = 30

func _ready():
	resize()

func set_size(new_size):
	size = new_size
	resize()

func resize(animating=false):
	var new_scale = Vector3(size, size, size)
	%shape.scale = new_scale
	%area.scale = new_scale
	if not animating or size >= Global.BUBBLE_ENTER_SIZE:
		%sprite.scale = new_scale
	else:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(%sprite, "scale", new_scale, 0.6)

func merge_bubbles(other_bubble):
	size += other_bubble.size * 0.25
	other_bubble.queue_free()
	# print(size)
	resize(true)

func _on_area_3d_area_entered(area):
	var other_bubble = area.get_bubble()
	if other_bubble.size > size:
		other_bubble.merge_bubbles(self)
	else:
		merge_bubbles(other_bubble)


func _on_body_entered(body):
	if body.collision_layer & Global.THORN_LAYER_BIT == Global.THORN_LAYER_BIT:
		Global.splash(get_parent(), position, scale)
		queue_free()

	if size >= Global.BUBBLE_ENTER_SIZE and body is CharacterBody3D:
		var collision_strength = linear_velocity.distance_squared_to(body.get_real_velocity())
		if collision_strength >= enter_bubble_strength:
			body.enter_bubble(self)
			queue_free()
