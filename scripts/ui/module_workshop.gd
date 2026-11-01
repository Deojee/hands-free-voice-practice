
extends Control

#@export var button = false:
	#get():
		#return false
	#set(value):
		#get_tree().root.content_scale_factor = 2.0

var workingModule : Module

var clips : Array[ReferenceClip]
var workingReferenceClip : ReferenceClip

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	get_tree().root.content_scale_factor = 2.0
	


func _on_main_menu_pressed() -> void:
	if Engine.is_editor_hint():
		return
	get_tree().root.content_scale_factor = 1.0
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)


func _on_load_file_pressed() -> void:
	
	pass # Replace with function body.
