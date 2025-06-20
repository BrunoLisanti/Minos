extends Control

@onready var volume_slider: HSlider = $PanelContainer/CenterContainer/VBoxContainer/Volume
@onready var sensitivity_slider: HSlider = $PanelContainer/CenterContainer/VBoxContainer/Sensitivity
@onready var bus_index := AudioServer.get_bus_index("Master")

@onready var config := ConfigFile.new()

const CONFIG_FILE := "user://cfg"

func _ready() -> void:
	var err := config.load(CONFIG_FILE)
	if (err != OK):
		config.set_value("OPTIONS", "SENSITIVITY", 1.)
		config.set_value("OPTIONS", "VOLUME", db_to_linear(AudioServer.get_bus_volume_db(bus_index)))
	
	volume_slider.value = config.get_value("OPTIONS", "VOLUME", db_to_linear(AudioServer.get_bus_volume_db(bus_index)))
	sensitivity_slider.value = config.get_value("OPTIONS", "SENSITIVITY", 1.)

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_tree_exiting() -> void:
	config.set_value("OPTIONS", "SENSITIVITY", sensitivity_slider.value)
	config.set_value("OPTIONS", "VOLUME", volume_slider.value)
	config.save(CONFIG_FILE)
