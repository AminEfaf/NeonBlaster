# Neon Blaster Game

## Project Overview

Neon Blaster thrusts you into a neon-drenched universe where you pilot a spaceship, tasked with obliterating waves of enemy spacecraft. Your mission is to survive as long as possible while annihilating as many adversaries as you can. Each wave intensifies the challenge with faster and fiercer enemy ships.

---

## Features

1. **Dynamic Gameplay**:
   - Navigate a neon universe and face relentless waves of enemies.
   - Automatic laser firing for seamless combat.

2. **Score Tracking**:
   - Monitor your score and aim to surpass your previous high score.

3. **Wave Progression**:
   - Enemy ships increase in number and speed with each wave.

4. **FPGA Integration**:
   - Real-time gameplay implemented on FPGA boards.

---

## How to Use

1. **Setup the FPGA Environment**:
   - Load the VHDL project files into your FPGA programming tool.
   - Compile and upload the design onto your FPGA board.

2. **Start the Game**:
   - Use the FPGA push-button to initiate the game.

3. **Control Your Spaceship**:
   - Movement: Use FPGA keys or joystick to maneuver.
   - Shooting: Lasers fire automatically upon detecting enemies.

4. **Survive and Score**:
   - Avoid enemy fire, destroy incoming ships, and achieve the highest score possible.

---

## Key Components

1. **FPGA Game Interface**:
   - **7-Segment Display**: Shows score and wave number.
   - **Push-Button**: Start, pause, or restart the game.
   - **LEDs**: Visual cues for critical game events.

2. **Game Logic**:
   - Automatic firing and collision detection.
   - Gravity effects and wave-based difficulty scaling.

---

## Feedback

We welcome your feedback and suggestions! Feel free to reach out or open an issue in this repository.
