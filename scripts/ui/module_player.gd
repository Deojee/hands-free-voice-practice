extends Control

var module : Module
var clipNum = 0

enum STATES {REFERENCE,RECORDING,PLAYBACK}
var state : STATES = STATES.REFERENCE
var paused : bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	pass

func _on_pause_pressed() -> void:
	pass # Replace with function body.
