extends Control

var modules : Array[Module] = []

const defaultModulePath = "res://defaultModules/"

func _ready() -> void:
	
	for file in DirAccess.get_files_at(defaultModulePath):
		modules.append(ModuleLoader.getModuleFromPath(defaultModulePath.path_join(file)))
	
	#above is placeholder, below is somewhat final
	
	for m in modules:
		var newDesc = preload(Constants.Paths.moduleDescElement).instantiate()
		newDesc.setup(m)
		$MarginContainer/VBoxContainer/VBoxContainer.add_child(newDesc)
		#print("Hey!")
	
	pass

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)
