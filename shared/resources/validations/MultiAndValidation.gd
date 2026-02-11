class_name MultiAndValidation extends Validation

@export var validators: Array[Validation] = []

func validate(new_text: String) -> bool:
	super(new_text)
	for validator: Validation in validators:
		if not validator.validate(new_text):
			_add_errors(validator.get_last_errors())
			return false
	return true
