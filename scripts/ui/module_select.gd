extends Control

var modules : Array[Module] = []

const defaultModulePath = "res://defaultModules/"
const downloadedModulePath = "user://downloadedModules"



func _ready() -> void:
	
	if !DirAccess.dir_exists_absolute(downloadedModulePath):
		DirAccess.make_dir_recursive_absolute(downloadedModulePath)
	
	loadModules()
	
	pass

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)


func _on_modules_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(downloadedModulePath))


func _on_refresh_pressed() -> void:
	loadModules()

func loadModules():
	for file in DirAccess.get_files_at(defaultModulePath):
		modules.append(ModuleLoader.getModuleFromPath(defaultModulePath.path_join(file)))
	
	
	for file in DirAccess.get_files_at(downloadedModulePath):
		modules.append(ModuleLoader.getModuleFromPath(downloadedModulePath.path_join(file)))
	
	
	#above is placeholder, below is somewhat final
	
	for m in modules:
		var newDesc = preload(Constants.Paths.moduleDescElement).instantiate()
		newDesc.setup(m)
		$MarginContainer/VBoxContainer/VBoxContainer.add_child(newDesc)
		#print("Hey!")
