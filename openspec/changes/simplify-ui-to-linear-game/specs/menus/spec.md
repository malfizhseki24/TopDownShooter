# Spec: Menus (Linear Stage Game)

## MODIFIED Requirements

### Requirement: Main Menu Structure
The main menu SHALL provide a simple interface for starting a new game and quitting.

**Changed from:** Roguelite menu with Daily Challenge, Seed Input, Load Seed
**Changed to:** Linear game menu with New Game, Options, Quit

#### Scenario: Player starts new game
**Given** the player is on the main menu
**When** the player clicks "NEW GAME"
**Then** the game starts from Room 1 with a fresh state
**And** any previous game progress is discarded

#### Scenario: Player views main menu options
**Given** the player launches the game
**When** the main menu loads
**Then** exactly three options are visible:
- "NEW GAME" button
- "OPTIONS" button (disabled, placeholder)
- "QUIT" button
**And** no seed input or daily challenge options are shown

---

### Requirement: Game Over Screen
The game over screen SHALL provide simple restart and quit options.

**Changed from:** Roguelite game over with Seed display, Retry (Same Seed), New Run
**Changed to:** Linear game over with Restart, Quit to Title

#### Scenario: Player restarts after game over
**Given** the player has died and the game over screen is shown
**When** the player clicks "RESTART"
**Then** the game restarts from Room 1
**And** all game state is reset (HP=100, room=1, enemies respawn)

#### Scenario: Player quits to title after game over
**Given** the player has died and the game over screen is shown
**When** the player clicks "QUIT TO TITLE"
**Then** the game returns to the main menu
**And** no seed or run statistics are displayed

#### Scenario: Game over displays simple statistics
**Given** the player has died
**When** the game over screen appears
**Then** only basic statistics are shown (enemies killed, time)
**And** no seed value is displayed

---

### Requirement: Pause Menu
The pause menu SHALL allow resuming, restarting, or quitting the game.

**Changed from:** Simple resume/quit only
**Changed to:** Resume, Restart, Quit to Menu

#### Scenario: Player restarts from pause menu
**Given** the game is paused
**When** the player clicks "RESTART"
**Then** the game unpauses
**And** the game restarts from Room 1

#### Scenario: Player quits from pause menu
**Given** the game is paused
**When** the player clicks "QUIT TO MENU"
**Then** the game returns to the main menu
**And** the current game state is discarded

---

### Requirement: Victory Screen
The victory screen SHALL provide simple play again and quit options without seed sharing.

**Changed from:** Roguelite victory with Seed display, Copy Seed, New Run (Harder)
**Changed to:** Linear victory with Play Again, Return to Menu

#### Scenario: Player wins and views victory screen
**Given** the player has defeated the Shadow Boar
**When** the victory screen appears
**Then** "VICTORY!" message is displayed
**And** basic statistics are shown (enemies killed, damage taken, time)
**And** no seed value or copy seed button is displayed

#### Scenario: Player plays again after victory
**Given** the victory screen is shown
**When** the player clicks "PLAY AGAIN"
**Then** the game restarts from Room 1
**And** all game state is reset

#### Scenario: Player returns to menu after victory
**Given** the victory screen is shown
**When** the player clicks "RETURN TO MENU"
**Then** the game returns to the main menu

---

## REMOVED Requirements

- **Daily Challenge**: Player can start a daily challenge with a fixed seed for all players. *Reason: Linear stage game does not need daily challenges.*

- **Seed Input**: Player can enter a specific seed to replay the same level layout. *Reason: Linear stage game has fixed room layouts; no procedural generation.*

- **Retry Same Seed**: Game over screen allows retrying with the same seed. *Reason: Linear game uses fixed rooms; "Restart" achieves the same result.*

- **Copy Seed**: Victory screen allows copying the run seed to clipboard. *Reason: Linear game has no seed system to share.*
