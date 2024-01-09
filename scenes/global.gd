extends Node

var splash_scene = preload('res://scenes/splash.tscn')

const BUBBLE_ENTER_SIZE = 2
const THORN_LAYER_BIT = 16

func splash(node, position, scale):
	var splash = splash_scene.instantiate()
	splash.position = position
	splash.scale = scale
	node.add_child(splash)
	splash.emitting = true
