extends Control

var modules : Array[Module] = []

func _ready() -> void:
	
	if true:
		var module : Module = Module.new()
		
		module.name = "Testing Module"
		
		var files = ["AudioClipOne","two","three","four","five","six","seven","eight","nine","ten"]
		
		for file in files:
			
			var newStream := ReferenceClip.new()
			newStream.audioStreamPath = "res://testingClips/" + file + ".ogg"
			newStream.transcript = file
			module.references.append(newStream)
		
		modules.append(module)
	
	#LJ module
	if true:
		var module : Module = Module.new()
		
		module.name = "LJ Cis Fem 1000"
		
		var files = ResourceLoader.list_directory(Constants.Paths.LJAudioSubsetPath)
		
		for file_name in files:
			print("Found file: ", file_name)
			if file_name.ends_with(".import"):
				continue
			var newStream = ReferenceClip.new()
			
			newStream.audioStreamPath = Constants.Paths.LJAudioSubsetPath.path_join(file_name)
			
			module.references.append(newStream)
		
		modules.append(module)
	
	#above is placeholder, below is somewhat final
	
	for m in modules:
		var newDesc = preload(Constants.Paths.moduleDescElement).instantiate()
		newDesc.setup(m)
		$MarginContainer/VBoxContainer/VBoxContainer.add_child(newDesc)
		print("Hey!")
	
	pass

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)
