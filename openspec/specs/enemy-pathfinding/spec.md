# Spec: Enemy Pathfinding

## Overview

Defines the pathfinding capability for enemy AI using NavigationAgent2D to navigate around walls and obstacles in complex room layouts.

## MODIFIED Requirements

### Requirement: Enemy Movement Uses Pathfinding

Enemies SHALL use NavigationAgent2D for pathfinding instead of direct movement, enabling navigation around walls and corners.

#### Scenario: Enemy navigates around wall

**Given** a wall is between the enemy and the player
**When** the enemy chases the player
**Then** the enemy shall follow a path around the wall
**And** the enemy shall not get stuck on the wall

#### Scenario: Enemy navigates L-shaped corner

**Given** an L-shaped corridor with the player around the corner
**When** the enemy chases the player
**Then** the enemy shall navigate the corner successfully
**And** reach the player's position

#### Scenario: Enemy reaches player in open area

**Given** no obstacles between enemy and player
**When** the enemy chases the player
**Then** the enemy shall move directly toward the player
**And** behavior shall match pre-pathfinding movement

#### Scenario: Path updates periodically

**Given** an enemy chasing the player
**When** the player moves to a new position
**Then** the enemy's path shall update within 0.25 seconds
**And** the enemy shall adjust course accordingly

## ADDED Requirements

### Requirement: Navigation Region in Game Scene

The game scene SHALL have a NavigationRegion2D that defines the walkable area for pathfinding.

#### Scenario: Navigation region exists

**Given** the game scene is loaded
**When** a room is generated
**Then** a NavigationRegion2D shall exist in the scene
**And** its polygon shall cover all walkable floor tiles

#### Scenario: Navigation updates on room change

**Given** the player enters a new room
**When** the room is loaded
**Then** the navigation polygon shall be regenerated
**And** pathfinding shall work in the new room

### Requirement: NavigationAgent2D per Enemy

Each enemy SHALL have a NavigationAgent2D node for path calculations.

#### Scenario: NavigationAgent2D configuration

**Given** an enemy scene
**When** the enemy is instantiated
**Then** a NavigationAgent2D node shall be present
**And** its radius shall match the enemy's collision radius
**And** path_desired_distance shall be 8.0
**And** target_desired_distance shall be 10.0

#### Scenario: NavigationAgent2D finds path

**Given** an enemy with NavigationAgent2D
**When** a target position is set
**Then** the agent shall calculate a valid path
**Or** return empty if no path exists

### Requirement: Pathfinding Performance

Pathfinding SHALL NOT significantly impact game performance.

#### Scenario: Path updates are throttled

**Given** multiple enemies chasing the player
**When** _physics_process runs
**Then** each enemy shall update its path at most once per 0.25 seconds
**And** not every frame

#### Scenario: Six enemies pathfinding

**Given** 6 enemies in a room
**When** all enemies are pathfinding
**Then** frame rate shall remain above 55 FPS
**And** gameplay shall feel smooth

### Requirement: Pathfinding Fallback

Enemies SHALL gracefully handle pathfinding failures.

#### Scenario: No valid path exists

**Given** an enemy with no valid path to player
**When** pathfinding fails
**Then** the enemy shall use direct movement
**And** not freeze or error

#### Scenario: NavigationAgent2D missing

**Given** an enemy without NavigationAgent2D
**When** pathfinding code runs
**Then** the enemy shall fall back to direct movement
**And** log a warning

## Related Capabilities

- `enemies` - Base enemy class and individual enemy types
- `ascii-room-builder` - Room generation that creates walkable areas
- `stage-rooms` - Room layouts that define navigation complexity
