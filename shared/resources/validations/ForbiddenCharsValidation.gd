class_name ForbiddenCharsValidation extends Validation

@export var forbidden_chars: Array[String] = ["{", "}", "[", "]"]

func validate(new_text: String) -> bool:
	super(new_text)
	for character: String in forbidden_chars:
		if new_text.contains(character):
			return false
	return true
