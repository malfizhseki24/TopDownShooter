# OpenSpec Instructions for Game Development

Instructions for AI game dev assistants using OpenSpec for spec-driven game development.

## TL;DR Quick Checklist

- Search existing work: `openspec spec list --long`, `openspec list`
- Decide scope: new game system vs modify existing system
- Pick a unique `change-id`: kebab-case, verb-led (`add-`, `update-`, `balance-`, `polish-`, `fix-`)
- Scaffold: `proposal.md`, `tasks.md`, `design.md` (only if needed), and delta specs per affected game system
- Write deltas: use `## ADDED|MODIFIED|REMOVED|RENAMED Mechanics`; include at least one `#### Gameplay:` per mechanic
- Validate: `openspec validate [change-id] --strict --no-interactive` and fix issues
- Request approval: Do not start implementation until proposal is approved

## Terminology Reference

| Software Term | Game Dev Term |
|---------------|---------------|
| Capability | Game System |
| Requirements | Mechanics / Behaviors |
| Scenarios | Gameplay Scenarios |
| API | Game Interface |
| Database | Save Data / Game State |
| Frontend | Game Objects / Entities |
| Tests | Playtesting |
| Deployment | Build / Release |
| Breaking Change | Save Breaking / Balance Change |

## Three-Stage Workflow

### Stage 1: Creating Feature Proposals
Create proposal when you need to:
- Add new game systems (combat, AI, inventory, etc.)
- Add new content (enemies, bosses, levels, items)
- Make balance changes affecting gameplay
- Change game architecture or patterns
- Add new assets (sprites, audio, VFX)
- Modify player experience or game feel

Triggers (examples):
- "Help me create a feature proposal"
- "Help me plan a new enemy"
- "Help me design a boss mechanic"
- "I want to add a new game system"
- "I want to balance the combat"

Loose matching guidance:
- Contains one of: `proposal`, `change`, `spec`, `feature`, `mechanic`, `system`, `enemy`, `boss`
- With one of: `create`, `plan`, `make`, `start`, `add`, `design`, `balance`

Skip proposal for:
- Bug fixes (restore intended behavior)
- Typos, formatting, comments
- Asset file organization
- Simple value tweaks during playtesting
- Editor/tooling configuration

**Workflow**
1. Review `docs/GDD.md`, `openspec/project.md`, `openspec list`, and `openspec list --specs` to understand current context.
2. Choose a unique verb-led `change-id` and scaffold `proposal.md`, `tasks.md`, optional `design.md`, and spec deltas under `openspec/changes/<id>/`.
3. Draft spec deltas using `## ADDED|MODIFIED|REMOVED Mechanics` with at least one `#### Gameplay:` per mechanic.
4. Run `openspec validate <id> --strict --no-interactive` and resolve any issues before sharing the proposal.

### Stage 2: Implementing Features
Track these steps as TODOs and complete them one by one.
1. **Read proposal.md** - Understand what's being built
2. **Read design.md** (if exists) - Review technical decisions
3. **Read tasks.md** - Get implementation checklist
4. **Implement tasks sequentially** - Complete in order
5. **Test in editor** - Run the scene and verify behavior
6. **Confirm completion** - Ensure every item in `tasks.md` is finished before updating statuses
7. **Update checklist** - After all work is done, set every task to `- [x]` so the list reflects reality
8. **Approval gate** - Do not start implementation until the proposal is reviewed and approved

### Stage 3: Archiving Features
After feature is complete and tested:
- Move `changes/[name]/` → `changes/archive/YYYY-MM-DD-[name]/`
- Update `specs/` if game systems changed
- Use `openspec archive <change-id> --skip-specs --yes` for asset-only changes
- Run `openspec validate --strict --no-interactive` to confirm the archived change passes checks

## Before Any Task

**Context Checklist:**
- [ ] Read `docs/GDD.md` for game design context
- [ ] Read relevant specs in `specs/[game-system]/spec.md`
- [ ] Check pending changes in `changes/` for conflicts
- [ ] Read `openspec/project.md` for conventions
- [ ] Run `openspec list` to see active features
- [ ] Run `openspec list --specs` to see existing game systems

**Before Creating Specs:**
- Always check if game system already exists
- Prefer modifying existing specs over creating duplicates
- Use `openspec show [spec]` to review current state
- If request is ambiguous, ask 1–2 clarifying questions before scaffolding

### Search Guidance
- Enumerate specs: `openspec spec list --long` (or `--json` for scripts)
- Enumerate changes: `openspec list`
- Show details:
  - Spec: `openspec show <spec-id> --type spec`
  - Change: `openspec show <change-id> --json --deltas-only`
- Full-text search: `rg -n "Mechanic:|Gameplay:" openspec/specs`

## Quick Start

### CLI Commands

```bash
# Essential commands
openspec list                  # List active feature changes
openspec list --specs          # List game system specs
openspec show [item]           # Display change or spec
openspec validate [item]       # Validate changes or specs
openspec archive <change-id> [--yes|-y]   # Archive after feature complete

# Project management
openspec init [path]           # Initialize OpenSpec
openspec update [path]         # Update instruction files

# Debugging
openspec show [change] --json --deltas-only
openspec validate [change] --strict --no-interactive
```

### Command Flags

- `--json` - Machine-readable output
- `--type change|spec` - Disambiguate items
- `--strict` - Comprehensive validation
- `--no-interactive` - Disable prompts
- `--skip-specs` - Archive without spec updates
- `--yes`/`-y` - Skip confirmation prompts

## Directory Structure

```
openspec/
├── project.md              # Project conventions
├── specs/                  # Current truth - what IS built
│   └── [game-system]/      # Single focused game system
│       ├── spec.md         # Mechanics and gameplay scenarios
│       └── design.md       # Technical patterns
├── changes/                # Proposals - what SHOULD change
│   ├── [feature-name]/
│   │   ├── proposal.md     # Why, what, impact
│   │   ├── tasks.md        # Implementation checklist
│   │   ├── design.md       # Technical decisions (optional)
│   │   └── specs/          # Delta changes
│   │       └── [game-system]/
│   │           └── spec.md # ADDED/MODIFIED/REMOVED
│   └── archive/            # Completed features
```

## Game System Categories

When organizing specs, use these standard game system categories:

| Category | Examples |
|----------|----------|
| **player** | Movement, combat, abilities, stats |
| **enemies** | AI behaviors, spawn systems, types |
| **boss** | Boss mechanics, phases, patterns |
| **combat** | Damage, hitboxes, projectiles, I-frames |
| **level** | Stage design, checkpoints, progression |
| **ui** | HUD, menus, dialogs, feedback |
| **audio** | SFX, music, ambient |
| **input** | Controls, key bindings, gamepad |
| **camera** | Follow behavior, screenshake |
| **game-state** | Save/load, game flow, progression |

## Creating Feature Proposals

### Decision Tree

```
New request?
├─ Bug fix restoring intended behavior? → Fix directly
├─ Typo/format/comment? → Fix directly
├─ New game system? → Create proposal
├─ New enemy/boss/content? → Create proposal
├─ Balance change? → Create proposal
├─ New asset type? → Create proposal
├─ Game feel improvement? → Create proposal
└─ Unclear? → Create proposal (safer)
```

### Proposal Structure

1. **Create directory:** `changes/[feature-id]/` (kebab-case, verb-led, unique)

2. **Write proposal.md:**
```markdown
# Feature: [Brief description of feature]

## Why
[1-2 sentences on design goal / player experience]

## What Changes
- [Bullet list of changes]
- [Mark balance changes with **BALANCE**]
- [Mark save-breaking changes with **BREAKING**]

## Impact
- Affected systems: [list game systems]
- Affected files: [key scenes/scripts/assets]
```

3. **Create spec deltas:** `specs/[game-system]/spec.md`
```markdown
## ADDED Mechanics
### Mechanic: New Ability
The player SHALL be able to...

#### Gameplay: Success case
- **WHEN** player presses input
- **THEN** ability activates with expected result

#### Gameplay: Cooldown case
- **WHEN** ability on cooldown
- **THEN** input is ignored

## MODIFIED Mechanics
### Mechanic: Existing Ability
[Complete modified mechanic with all gameplay scenarios]

## REMOVED Mechanics
### Mechanic: Old Ability
**Reason**: [Why removing]
**Migration**: [How to handle existing saves]
```

4. **Create tasks.md:**
```markdown
## 1. Core Implementation
- [ ] 1.1 Create scene/script structure
- [ ] 1.2 Implement core mechanic
- [ ] 1.3 Add visual feedback
- [ ] 1.4 Add audio feedback

## 2. Integration
- [ ] 2.1 Connect to existing systems
- [ ] 2.2 Update UI/HUD if needed
- [ ] 2.3 Test with enemies/dummies

## 3. Polish
- [ ] 3.1 Add juice (screenshake, particles)
- [ ] 3.2 Balance values
- [ ] 3.3 Playtest and iterate
```

5. **Create design.md when needed:**
Create `design.md` if any of the following apply:
- Cross-cutting change (multiple game systems)
- New game architecture pattern
- Complex AI or boss behavior
- Performance-critical systems
- Save data structure changes

Minimal `design.md` skeleton:
```markdown
## Context
[Game design goal, constraints, player experience]

## Goals / Non-Goals
- Goals: [...]
- Non-Goals: [...]

## Technical Decisions
- Decision: [What and why]
- Alternatives: [Options + rationale]

## Balance Values
| Property | Value | Notes |
|----------|-------|-------|
| HP | 100 | Base player health |
| Damage | 25 | Per arrow |

## Asset Requirements
- Sprites: [list needed sprites]
- Audio: [list needed sounds]
- VFX: [list needed effects]

## Open Questions
- [...]
```

## Spec File Format

### Critical: Gameplay Scenario Formatting

**CORRECT** (use #### headers):
```markdown
#### Gameplay: Player dashes successfully
- **WHEN** player presses dash button
- **THEN** player moves quickly in input direction with I-frames
```

**WRONG** (don't use bullets or bold):
```markdown
- **Gameplay: Player dashes**  ❌
**Gameplay**: Player dashes     ❌
### Gameplay: Player dashes      ❌
```

Every mechanic MUST have at least one gameplay scenario.

### Mechanic Wording
- Use SHALL/MUST for definitive behaviors (avoid should/may unless intentionally variable)
- Include specific values for balance (HP, damage, speed, cooldowns)

### Delta Operations

- `## ADDED Mechanics` - New game systems/features
- `## MODIFIED Mechanics` - Changed behavior or balance
- `## REMOVED Mechanics` - Deprecated features
- `## RENAMED Mechanics` - Name changes

#### When to use ADDED vs MODIFIED
- ADDED: Introduces a new game system or mechanic that can stand alone (e.g., adding "Parry System")
- MODIFIED: Changes balance values, behavior, or acceptance criteria. Always include the full updated mechanic with all gameplay scenarios.
- RENAMED: Use when only the name changes. If behavior also changes, use RENAMED plus MODIFIED.

Example for balance change:
```markdown
## MODIFIED Mechanics
### Mechanic: Player Health
The player SHALL have 80 HP (reduced from 100).

#### Gameplay: Player takes damage
- **WHEN** enemy hits player
- **THEN** player HP decreases by enemy damage value
```

## Troubleshooting

### Common Errors

**"Change must have at least one delta"**
- Check `changes/[name]/specs/` exists with .md files
- Verify files have operation prefixes (## ADDED Mechanics)

**"Mechanic must have at least one gameplay scenario"**
- Check scenarios use `#### Gameplay:` format (4 hashtags)
- Don't use bullet points or bold for scenario headers

**Silent scenario parsing failures**
- Exact format required: `#### Gameplay: Name`
- Debug with: `openspec show [change] --json --deltas-only`

### Validation Tips

```bash
# Always use strict mode for comprehensive checks
openspec validate [change] --strict --no-interactive

# Debug delta parsing
openspec show [change] --json | jq '.deltas'

# Check specific mechanic
openspec show [spec] --json -r 1
```

## Happy Path Script

```bash
# 1) Explore current state
openspec spec list --long
openspec list

# 2) Choose feature id and scaffold
FEATURE=add-shadow-stalker-enemy
mkdir -p openspec/changes/$FEATURE/{specs/enemies}
printf "## Why\n...\n\n## What Changes\n- ...\n\n## Impact\n- ...\n" > openspec/changes/$FEATURE/proposal.md
printf "## 1. Implementation\n- [ ] 1.1 ...\n" > openspec/changes/$FEATURE/tasks.md

# 3) Add deltas (example)
cat > openspec/changes/$FEATURE/specs/enemies/spec.md << 'EOF'
## ADDED Mechanics
### Mechanic: Shadow Stalker Enemy
The game SHALL include a teleporting shadow enemy with 60 HP.

#### Gameplay: Teleport behavior
- **WHEN** 2 seconds have passed since last teleport
- **THEN** enemy teleports to position near player

#### Gameplay: Attack behavior
- **WHEN** player is within 64px after teleport
- **THEN** enemy deals 20 damage to player
EOF

# 4) Validate
openspec validate $FEATURE --strict --no-interactive
```

## Multi-System Example

```
openspec/changes/add-dash-ability/
├── proposal.md
├── tasks.md
└── specs/
    ├── player/
    │   └── spec.md   # ADDED: Dash mechanic, cooldown
    ├── combat/
    │   └── spec.md   # ADDED: I-frame system
    └── audio/
        └── spec.md   # ADDED: Dash SFX
```

## Best Practices

### Game Dev Simplicity First
- Default to single-scene implementations
- Prefer composition over inheritance for game objects
- Keep balance values in one place (constants or export vars)
- Choose proven patterns (state machines, signals)

### When to Add Complexity
Only add complexity with:
- Performance issues proven by profiling
- Multiple enemy types sharing behavior (base class)
- Complex boss patterns (state machine)
- Save/load requirements

### Clear References
- Use `scripts/player/player.gd:42` format for code locations
- Reference specs as `specs/combat/spec.md`
- Reference GDD as `docs/GDD.md#section`

### Game System Naming
- Use noun-first: `player-combat`, `enemy-ai`, `boss-phases`
- Single purpose per system
- Split if description needs "AND"

### Feature ID Naming
- Use kebab-case: `add-shadow-stalker`, `balance-player-damage`
- Prefer verb-led prefixes: `add-`, `update-`, `balance-`, `polish-`, `fix-`
- Ensure uniqueness; if taken, append `-2`, `-3`, etc.

## Game Dev Specific Sections

### Asset Pipeline Checklist
When a feature requires new assets:
- [ ] Sprites generated (Pixellab prompts in GDD)
- [ ] Audio sourced/created (Freesound, etc.)
- [ ] VFX created/sourced
- [ ] All assets imported to correct folders
- [ ] Import settings configured (pixel art: filter disabled)

### Playtesting Checklist
After implementation:
- [ ] Feature works in isolation
- [ ] Feature integrates with existing systems
- [ ] No console errors/warnings
- [ ] Performance is acceptable (60 FPS)
- [ ] Game feel is satisfactory

### Balance Change Format
```markdown
## MODIFIED Mechanics
### Mechanic: [Name]

| Property | Old Value | New Value | Reason |
|----------|-----------|-----------|--------|
| HP | 100 | 80 | Too tanky |
| Damage | 20 | 25 | More impact |
```

## Error Recovery

### Feature Conflicts
1. Run `openspec list` to see active changes
2. Check for overlapping game systems
3. Coordinate feature order
4. Consider combining proposals

### Validation Failures
1. Run with `--strict` flag
2. Check JSON output for details
3. Verify spec file format
4. Ensure gameplay scenarios properly formatted

### Missing Context
1. Read GDD first
2. Check related specs
3. Review recent archives
4. Ask for clarification

## Quick Reference

### Stage Indicators
- `changes/` - Proposed, not yet implemented
- `specs/` - Implemented and working
- `archive/` - Completed features

### File Purposes
- `proposal.md` - Why and what (design intent)
- `tasks.md` - Implementation steps
- `design.md` - Technical decisions, balance values
- `spec.md` - Mechanics and gameplay behavior

### CLI Essentials
```bash
openspec list              # What features are in progress?
openspec show [item]       # View details
openspec validate --strict --no-interactive  # Is it correct?
openspec archive <change-id> [--yes|-y]  # Mark feature complete
```

Remember: GDD is the vision. Specs are the implementation truth. Keep them in sync.
