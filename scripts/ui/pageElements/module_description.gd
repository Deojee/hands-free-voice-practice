extends Control

var myModule : Module

func setup(module : Module):
	$VBoxContainer/name.text = module.name
	$VBoxContainer/clips.text = "Clips: " + str(module.getClipNum())
	$VBoxContainer/length.text = str(module.getLength()) + " seconds"
	
	pass


func _on_button_pressed() -> void:
	Globals.currentModule = myModule
	get_tree().change_scene_to_file(Constants.Paths.modulePlayer)
