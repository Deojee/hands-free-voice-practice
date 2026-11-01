
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
	
	workingModule = Module.new()
	
	
	var fd : FileDialog = %FileDialog
	
	


func _on_main_menu_pressed() -> void:
	if Engine.is_editor_hint():
		return
	get_tree().root.content_scale_factor = 1.0
	get_tree().change_scene_to_file(Constants.Paths.mainMenu)

func updateTranscriptButtonList():
	
	var transButton = %TranscriptButton
	var pos = getCurrentClipIndex()
	
	for c in %referenceClipHolder.get_children():
		c.queue_free()
	
	var i = 0
	for r in workingModule.references:
		
		var newButton : Button = %TranscriptButton.duplicate()
		newButton.get_child(0).text = r.transcript.replace("\n","") if r.transcript != "" else "No transcript"
		newButton.button_down.connect(changeWorkingReferenceClip.bind(r))
		%referenceClipHolder.add_child(newButton)
		
		if i == pos:
			newButton.modulate = Color.RED
		
		i += 1
		
	
	pass

func changeWorkingReferenceClip(newRefClip):
	
	#print("called!!")
	
	if newRefClip == null:
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
	_on_repeatable_button_toggled(true)
	%repeatNum.value = wr.numRepeat
	
	%"Delete Clip".disabled = false
	
	updateTranscriptButtonList()


func _on_load_file_pressed() -> void:
	
	pass # Replace with function body.


func _on_module_name_text_changed(new_text: String) -> void:
	workingModule.name = new_text


func _on_transcript_edit_text_changed() -> void:
	workingReferenceClip.transcript = %transcriptEdit.text
func _on_transcript_edit_focus_exited() -> void:
	#would be in the other one but could cause lag :/
	updateTranscriptButtonList()


func _on_record_button_pressed() -> void:
	pass # Replace with function body.


func _on_play_button_pressed() -> void:
	pass # Replace with function body.



func _on_repeatable_button_toggled(toggled_on: bool) -> void:
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


func _on_load_pressed() -> void:
	print("hey")
	%FileDialog.popup()
	pass # Replace with function body.


func _on_export_pressed() -> void:
	pass # Replace with function body.


func _on_save_pressed() -> void:
	pass # Replace with function body.
