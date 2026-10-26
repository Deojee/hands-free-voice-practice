extends Control

var myModule : Module

func setup(module : Module):
	$MarginContainer/VBoxContainer/name.text = module.name
	$MarginContainer/VBoxContainer/clips.text = "Clips: " + str(module.getClipNum())
	$MarginContainer/VBoxContainer/length.text = str(module.getLength()) + " seconds"
	myModule = module
	pass


func _on_button_pressed() -> void:
	Globals.currentModule = myModule
	get_tree().change_scene_to_file(Constants.Paths.modulePlayer)
