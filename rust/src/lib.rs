use godot::prelude::*;

struct MyExtension;

mod player;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}

