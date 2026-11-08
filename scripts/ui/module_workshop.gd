
extends Control

#@export var button = false:
	#get():
		#return false
	#set(value):
		#get_tree().root.content_scale_factor = 2.0

var workingModule : Module

var clips : Array[ReferenceClip]
var workingReferenceClip : ReferenceClip



#always increases when the debug label changes
var debugNum = 0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	get_tree().root.content_scale_factor = 2.0
	
	workingModule = Module.new()
	
	
	var fd : FileDialog = %FileDialog
	
	


func _on_main_menu_pressed() -> void:
	if Engine.is_editor_hint():
		return
	get_tree().root.content_scale_factor = 1.0
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)

const TRANSBUTTON_LABEL_INDEX = 0
const TRANSBUTTON_NOSOUND_INDEX = 1
const TRANSBUTTON_NOCALLBACK_INDEX = 2
const TRANSBUTTON_REPITITIONS_INDEX = 3
func updateTranscriptButtonList():
	
	var transButton = %TranscriptButton
	var pos = getCurrentClipIndex()
	
	for c in %referenceClipHolder.get_children():
		c.queue_free()
	
	var i = 0
	for r in workingModule.references:
		
		var newButton : Button = %TranscriptButton.duplicate()
		newButton.button_down.connect(changeWorkingReferenceClip.bind(r))
		%referenceClipHolder.add_child(newButton)
		
		var hbox = newButton.get_child(0)
		var transLabel : Label = hbox.get_child(TRANSBUTTON_LABEL_INDEX)
		var nosoundWarning : TextureRect = hbox.get_child(TRANSBUTTON_NOSOUND_INDEX)
		var noCallback : MarginContainer = hbox.get_child(TRANSBUTTON_NOCALLBACK_INDEX)
		var repitionsLabel : Label = hbox.get_child(TRANSBUTTON_REPITITIONS_INDEX)
		
		
		transLabel.text = r.transcript.replace("\n","") if r.transcript != "" else "No transcript"
		nosoundWarning.visible = r.sound == null
		noCallback.visible = r.noRepeat
		
		repitionsLabel.visible = r.numRepeat != 1
		repitionsLabel.text = str(r.numRepeat)
		
		if i == pos:
			newButton.modulate = Color.RED
		elif r.noRepeat:
			newButton.modulate = Color.MEDIUM_PURPLE
		
		i += 1
		
	
	pass

func changeWorkingReferenceClip(newRefClip):
	
	if newRefClip == workingReferenceClip:
		return
	
	if isRecording: #abort the recording if recording
		recorder.stop_capturing()
		%recordButton.text = RECORD_BUTTON_STOP
	
	if newRefClip == null:
		workingReferenceClip = null
		%transcriptEdit.text = "null"
		%repeatableButton.button_pressed = false
		%repeatNum.value = 1
		
		%"Delete Clip".disabled = true
		%noReferenceClip.visible = true
		return
	%noReferenceClip.visible = false
	
	newRefClip = newRefClip as ReferenceClip
	workingReferenceClip = newRefClip
	var wr = workingReferenceClip
	
	%transcriptEdit.text = wr.transcript
	%repeatableButton.button_pressed = !wr.noRepeat
	_on_repeatable_button_toggled(!wr.noRepeat)
	%repeatNum.value = wr.numRepeat
	
	%"Delete Clip".disabled = false
	
	%playButton.disabled = workingReferenceClip.sound == null
	
	updateTranscriptButtonList()

##loading an audio file into the current reference clip
func _on_load_file_pressed() -> void:
	
	pass # Replace with function body.


func _on_module_name_text_changed(new_text: String) -> void:
	workingModule.name = new_text


func _on_transcript_edit_text_changed() -> void:
	workingReferenceClip.transcript = %transcriptEdit.text
func _on_transcript_edit_focus_exited() -> void:
	#would be in the other one but could cause lag :/
	updateTranscriptButtonList()

@onready var recorder : DirectAudioInputRecorder = $DirectAudioInputRecorder
@onready var audioPlayer : AudioStreamPlayer = $AudioStreamPlayer
const RECORD_BUTTON_START = "Record"
const RECORD_BUTTON_STOP = "Stop Record"
var isRecording : bool:
	get():
		return recorder._is_recording
	set(value):
		print("cannot set recorder recording")
func _on_record_button_pressed() -> void:
	if !isRecording:
		recorder.start_capturing()
		%recordButton.text = RECORD_BUTTON_STOP
		return
	
	recorder.stop_capturing()
	%recordButton.text = RECORD_BUTTON_START
	%playButton.disabled = false
	var recording : AudioStream  = recorder.get_recording()
	workingReferenceClip.sound = recording
	updateTranscriptButtonList()
	
	if %autoplay.button_pressed:
		_on_play_button_pressed()
	

##plays the audio file associated with the current reference clip
func _on_play_button_pressed() -> void:
	if !workingReferenceClip:
		setDebugLabel("No reference clip!")
	if !workingReferenceClip.sound:
		setDebugLabel("No reference clip sound!")
	
	print("playing the sound!")
	if audioPlayer.stream != workingReferenceClip.sound:
		audioPlayer.stream = workingReferenceClip.sound
	audioPlayer.call_deferred("play")
	pass # Replace with function body.



func _on_repeatable_button_toggled(toggled_on: bool) -> void:
	if !workingReferenceClip:
		return
	
	workingReferenceClip.noRepeat = !toggled_on
	if workingReferenceClip.noRepeat:
		%repeatableButton.text = "Not repeated"
	else:
		%repeatableButton.text = "User will repeat"


func _on_repeat_num_value_changed(value: float) -> void:
	workingReferenceClip.numRepeat = value


func _on_description_box_text_changed() -> void:
	workingModule.description = %"description box".text


func getCurrentClipIndex() -> int:
	
	var i : int = 0
	for r in workingModule.references:
		if r == workingReferenceClip:
			return i
		i += 1
	
	return -1

func _on_add_clip_pressed() -> void:
	var newClip = ReferenceClip.new()
	workingModule.references.append(newClip)
	changeWorkingReferenceClip(newClip)
	updateTranscriptButtonList()


func _on_insert_new_clip_pressed() -> void:
	var newClip = ReferenceClip.new()
	var pos = getCurrentClipIndex()
	workingModule.references.insert(pos,newClip)
	changeWorkingReferenceClip(newClip)
	updateTranscriptButtonList()


func _on_delete_clip_pressed() -> void:
	#var pos = getCurrentClipIndex()
	workingModule.references.erase(workingReferenceClip)
	changeWorkingReferenceClip(null)
	updateTranscriptButtonList()


##loading a module
func _on_load_pressed() -> void:
	print("hey")
	var fd = %FileDialog
	fd.clear_filename_filter()
	fd.add_filter("*.mod")
	fd.popup()
	
	#not complete
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

	
	

##exporting a module

func _on_export_pressed() -> void:
	
	
	
	
	
	pass # Replace with function body.

const exportPath : String = "user://exports"
##saving a module
func _on_save_pressed() -> void:
	
	if workingModule.name == "":
		setDebugLabel(" Module has no name!")
		return 
	
	
	var exportName = "export" + workingModule.name
	const audioFileFolderName = "audioFiles"
	const metaDataFileName = "metadata.json"
	
	var currentExportFolder = exportPath.path_join(exportName)
	var currentExportAudioFilesFolder = currentExportFolder.path_join(audioFileFolderName)
	
	if DirAccess.dir_exists_absolute(currentExportFolder):
		setDebugLabel("folder \"" + currentExportFolder + "\" already exists!")
		return 
	
	#create the folder that we put everything in
	#and then the sub folder that we put the audiofiles in
	var error1 = DirAccess.make_dir_recursive_absolute(currentExportFolder)
	var error2 = DirAccess.make_dir_recursive_absolute(currentExportAudioFilesFolder)
	
	#create the metadata file immediately in currentExportFolder
	var metaDataFile = FileAccess.open(currentExportFolder.path_join(metaDataFileName), FileAccess.WRITE)
	
	const audioFilePrefix : String = "audioClip"
	var i : int = 0
	for rc in workingModule.references:
		rc = rc as ReferenceClip
		if rc.sound == null:
			continue
		i += 1
		
		var audioFileName = audioFilePrefix + str(i) + ".wav"
		var audioFileLocalPath = currentExportAudioFilesFolder.path_join(audioFileName)
		
		
		rc.audioStreamLocation = ""
		rc.audioStreamPath = audioFileLocalPath
		
		var json_string = JSON.stringify(rc.getDict())
		# Store the save dictionary as a new line in the save file.
		metaDataFile.store_line(json_string)
		
		var wavSound = rc.sound as AudioStreamWAV
		wavSound.save_to_wav(audioFileLocalPath)
		
		pass
	
	pass # Replace with function body.

func setDebugLabel(errorText : String):
	debugNum += 1
	%debugLabel.text = str(debugNum) + " Debug: " + errorText

func _on_move_up_pressed() -> void:
	var pos = getCurrentClipIndex()
	if pos == 0:
		return
	workingModule.references.erase(workingReferenceClip)
	workingModule.references.insert(pos - 1,workingReferenceClip)
	
	updateTranscriptButtonList()


func _on_move_down_pressed() -> void:
	var pos = getCurrentClipIndex()
	if pos == workingModule.references.size() - 1:
		return
	workingModule.references.erase(workingReferenceClip)
	workingModule.references.insert(pos + 1,workingReferenceClip)
	
	updateTranscriptButtonList()


func _on_open_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(exportPath))


func _on_audio_stream_player_finished() -> void:
	print("finished")
	pass # Replace with function body.
