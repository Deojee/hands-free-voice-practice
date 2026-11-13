extends Resource
class_name Module

var name : String
var description : String
var references : Array[ReferenceClip]

var totalLength : float = 0 #calculated during save
var numClips : int = 0 #calculated during save

func getClipNum():
	return references.size()
func getLength():
	var sum = 0
	for clip in references:
		sum += clip.getLength()
	return sum


func getDict():
	
	numClips = references.size()
	totalLength = 0.0
	for clip in references:
		if !clip.sound:
			continue
		totalLength += clip.sound.get_length()
	
	return {
		"name" : name,
		"description" : description,
		"totalLength" : totalLength,
		"numClips" : numClips,
	}
