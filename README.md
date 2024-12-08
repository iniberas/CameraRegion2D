# CameraRegion2D
A simple [Godot](https://godotengine.org/) addon for managing `Camera2D` transitions and behaviors using defined regions. Easily add camera transitions, shake effects, and region-specific configurations to your game.

<p align="center">
  <img src="./demo/demo.gif" alt="demo" width="640">
</p>

## Installation
1. Download or clone this repository.
2. Copy the addon folder into your project's `addons/` directory.
3. Enable the addon in your Godot project via **Project Settings > Plugins**.

## Usage
1. Add a `CameraRegionController2D` node to your scene.
2. Add `CameraRegion2D` nodes as children of the `CameraRegionController2D` to specify the regions.
3. Assign the `target_node` (e.g., the player) and the `camera` to the `CameraRegionController2D`.
4. Customize transitions using the `CameraTransition` resource.
5. Optionally, connect to signals such as `target_entered_region` or `shake_started` for further control.

**Note:**  
Methods and variables prefixed with `_` are considered private and should not be accessed outside their source code.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.  
The demo assets are from [Kenney](https://kenney.nl/).
