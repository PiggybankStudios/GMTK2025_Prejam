extends Node

# This script is autoloaded and acts as a singleton where we can store global variables, constants, etc.
# "Gl" is short for "Global" and is shortened because it needs to be typed very often

# #===========================#
# |         Constants         |
# #===========================#
const TARGET_FRAMERATE: float = 60.0;
const TARGET_SECS: float = (1.0 / TARGET_FRAMERATE);
const LOOK_UP_DOWN_CLAMP_EPSILON: float = 0.001;
const MOUSE_SENSITIVITY: float = 0.1;

# #===========================#
# |         Variables         |
# #===========================#
