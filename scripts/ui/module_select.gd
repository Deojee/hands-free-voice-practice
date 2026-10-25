extends Control

var modules : Array[Module] = []

func _ready() -> void:
	
	var module : Module = Module.new()
	
	module.name = "Testing Module"
	
	var files = ["AudioClipOne","two","three","four","five","six","seven","eight","nine","ten"]
	
	for file in files:
		var audioStream = load("res://testingClips/" + file + ".ogg")
		var newStream = ReferenceClip.new()
		newStream.sound = audioStream
		newStream.transcript = file
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
