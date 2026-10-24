extends Resource
class_name Module

var name : String
var references : Array[ReferenceClip]

func getClipNum():
	return references.size()
func getLength():
	var sum = 0
	for clip in references:
		sum += clip.getLength()
	return sum
