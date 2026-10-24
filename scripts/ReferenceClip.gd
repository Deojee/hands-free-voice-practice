extends Resource
class_name ReferenceClip

var transcript : String
var sound : AudioStream

func getLength() -> float:
	return sound.get_length()
