extends Node3D

var bubble_scene = preload("res://scenes/bubble.tscn")

var bubbles_count = 0
var bubbles_info = []

func _instantiate_bubbles():
	for i in bubbles_info:
		var b = bubble_scene.instantiate()
		b.position = i["pos"]
		b.set_size(i["size"])
		add_child(b)

func _respawn():
	# if not Engine.is_editor_hint():
	if get_tree():
		await get_tree().create_timer(2.0).timeout
	_instantiate_bubbles()
	_recalc_bubbles()

func _on_bubble_exited():
	bubbles_count -= 1
	if bubbles_count <= 0:
		_respawn()

func _recalc_bubbles(new_info=false):
	bubbles_count = 0
	if new_info:
		bubbles_info = []
	for c in get_children():
		if c is Bubble:
			c.tree_exited.connect(_on_bubble_exited)
			bubbles_count += 1
			if new_info:
				bubbles_info.append({ "pos": c.position, "size": c.size })

func _ready():
	_recalc_bubbles(true)
