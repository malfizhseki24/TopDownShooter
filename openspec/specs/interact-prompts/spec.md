# interact-prompts Specification

## Purpose
World-space contextual interaction prompts that float above interactable objects when the player is in range.

## Requirements
### Requirement: Contextual Interaction Prompts

Interactable objects (heal shrines, portals) SHALL display floating world-space `[E]` prompts when the player is within interaction range.

#### Scenario: Prompt appears when player approaches

- **WHEN** the player enters the interaction range (48px) of an interactable
- **THEN** an `[E]` key label appears 16px above the interactable sprite
- **AND** a sub-label below shows the action name ("Heal", "Enter")
- **AND** the prompt fades in (alpha 0 to 1 over 0.15 seconds) and floats up 4px

#### Scenario: Prompt disappears when player leaves

- **WHEN** the player exits the interaction range of an interactable
- **THEN** the prompt fades out (alpha 1 to 0 over 0.1 seconds)

#### Scenario: Prompt has idle bob animation

- **WHEN** the interact prompt is visible
- **THEN** it bobs vertically +/-1px with a sine wave period of 1.5 seconds

#### Scenario: Heal shrine prompt styling

- **WHEN** an interact prompt is shown for a heal shrine
- **THEN** the key label shows `[E]` in `#f1f1f1` (white, 7px font) with 1px `#0f0f0f` drop shadow
- **AND** the sub-label shows "Heal" in `#70c1b3` (green tint, 5px font) at 60% opacity
- **AND** the prompt disappears after the shrine is used

#### Scenario: Active portal prompt styling

- **WHEN** an interact prompt is shown for an active portal (room cleared)
- **THEN** the key label shows `[E]` in `#f1f1f1` (white, 7px font)
- **AND** the sub-label shows "Enter" in `#f1f1f1` at 60% opacity

#### Scenario: Locked portal message

- **WHEN** the player first approaches a portal that is not yet active (enemies remain)
- **THEN** a red-tinted (`#e94560`) text "Defeat all enemies" appears briefly (no [E] key prompt)
- **AND** the text fades out after 2 seconds and does not reappear

#### Scenario: Prompts are world-space

- **WHEN** interact prompts are rendered
- **THEN** they are Control nodes parented to the interactable scene (not the HUD CanvasLayer)
- **AND** they move with the interactable in world space
- **AND** the camera affects their screen position naturally
