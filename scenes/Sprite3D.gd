@tool
extends Sprite3D

func _ready():
	if not Engine.is_editor_hint():
		transparency = 1
		var tween = get_tree().create_tween()
		tween.tween_property(self, "transparency", 0, 5)

func _process(delta):
	position.y = cos(get_parent().position.x + get_parent().position.z + Time.get_ticks_msec()/500.0) * 0.3 * scale.y
	if scale.z > Global.BUBBLE_ENTER_SIZE:
		scale.x = scale.z * 0.9 + sin(Time.get_ticks_msec()/100.0) * scale.z * 0.1
		scale.y = scale.z * 0.9 + cos(Time.get_ticks_msec()/100.0) * scale.z * 0.1
