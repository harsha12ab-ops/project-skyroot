# Project Skyroot

Project Skyroot is an original lightweight mobile action-adventure game built with Godot 4.

## Foundation

Phase 0 establishes a responsive 1280×720 landscape project, a mobile-friendly OpenGL compatibility renderer, and a polished animated bootstrap scene.

Phase 1 adds the reusable `CharacterBody2D` hero, shared male/female cutout rig, responsive movement controller, smooth gameplay camera, and the production movement lab.

## Run locally

Open this folder in Godot 4.x Standard and run the project. The main scene is `scenes/bootstrap/bootstrap.tscn`.

From the bootstrap, press Enter or Space to enter the Movement Lab.

- A / D: move
- Space: jump; release early for a short-hop
- V: toggle the male/female hero variant
- F9: run the Movement Lab's full development playtest replay

## Project structure

- `assets/` contains production art, audio, and fonts.
- `data/` contains game data and configuration resources.
- `scenes/` contains bootstrap, game, and shared UI scenes.
- `scripts/` contains core and UI scripts.
- `tests/` contains automated checks as they are introduced.
