extends Control


func _on_modules_pressed() -> void:
	get_tree().change_scene_to_file(Constants.Paths.moduleSelect)



func _on_quit_pressed() -> void:
	get_tree().quit(0)
