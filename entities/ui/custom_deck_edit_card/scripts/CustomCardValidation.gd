class_name MultiValidationNode extends Control

signal valid()
signal invalid()

@export var validation_fields: Array[LineEditValidation]
@export var validation_text_edit: Array[TextEditValidation]

func _ready() -> void:
	_setup_validation_fields()
	_setup_text_edits()

func _setup_validation_fields() -> void:
	for field: LineEditValidation in validation_fields:
		field.valid.connect(_validate_all)
		field.validation_failed.connect(_validate_all)
		if not field.is_valid():
			invalid.emit()

func _setup_text_edits() -> void:
	for text_edit: TextEditValidation in validation_text_edit:
		text_edit.valid.connect(_validate_all)
		text_edit.validation_failed.connect(_validate_all)
		if not text_edit.is_valid():
			invalid.emit()

func _validate_all() -> void:
	var is_valid: bool = _field_validated()
	if is_valid:
		is_valid = _text_edit_validate()
	if is_valid:
		valid.emit()
		return
	invalid.emit()

func _field_validated() -> bool:
	for field: LineEditValidation in validation_fields:
		if not field.is_valid():
			return false
	return true

func _text_edit_validate() -> bool:
	for text_edit: TextEditValidation in validation_text_edit:
		if not text_edit.is_valid():
			return false

	return true