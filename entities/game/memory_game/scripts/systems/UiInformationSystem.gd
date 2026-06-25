class_name UiInformationSystem extends Node

var _elements: Dictionary[String, Control] = {}

func register_ui_element(element_name: String, control: Control) -> bool:
	if _elements.has(element_name):
		return false
	_elements.set(element_name, control)
	return true

func get_ui_element(searched_name: String) -> Control:
	if _elements.has(searched_name):
		return _elements.get(searched_name)
	return null

func get_all_elements() -> Dictionary[String, Control]:
	return _elements

func get_all_names() -> Array[String]:
	return _elements.keys()