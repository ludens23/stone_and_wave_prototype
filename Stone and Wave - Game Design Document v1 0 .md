# Stone and Wave - Game Design Document v1.0 - Prototype 1

---

## Game Overview

**Title:** Stone and Wave

**Genre:** Infinite Runner / Puzzle

**Platform:** Web & Windows (Godot 4.5)

**Team:** Lingshan Xiong & Harry Tang

**Version:** Prototype 1.0

### Core Concept

An infinite runner game where players control an entity that can transform between **particle** and **wave** states, using wave-particle duality to overcome obstacles and survive as long as possible.

Players run horizontally through an endless level, transforming between rigid particles and flexible waves to solve environmental puzzles.

**Goal:** Achieve high survival time and solve puzzles quickly. Failure occurs when energy drops to 0.

---

## **Key Pillars**

- **Transformation (Core Idea):** The player can switch between two forms:
    - **Particle:**
        - Represents rigidity and deterministic interactions.
        - In this form, the object moves horizontally with no energy consumption (if no events occur).
        - Full of event-based interactions
            - collide with obstacles and loss energy, can divide into smaller particles when energy is high (indicated by colour). The fragments reassemble after a few seconds.
            - receive energy from environment (e.g beams)
        - ** Object Oriented Ontology(Conceptual)*
            - withdraw, fission/fusion, surface interactions(wave) = continuous
    - **Wave:**
        - Represents flexibility and uncertainty.
        - In this form, the object continuously loses energy at a rate determined by the medium.
        - Waves can penetrate walls by converting energy into amplitude; the width of the wave determines penetration ability.
        - Represents all statistical possible states of particles. When the wave collapses back into a particle, it randomly selects a possible particle form.
        - *Relational Ontology*(*Conceptual)*
            - interaction = discrete events as basic elements
- **Puzzle Feature:** Players must choose the appropriate form to pass specific obstacles. Some puzzles have unique solutions(50%); others can be solved by either form. This dual‑solution approach encourages experimentation and strategy.

---

## **Core Mechanics**

### Movement and Energy System

**Particle Mode (Default State)**

- **Basic Properties:**
    - Horizontal movement only (no vertical control)
    - Energy does not decrease unless interacting with obstacles.
    - Can collide and interact with physical objects
    - Can absorb energy from light beams
    - Visual feedback: Color intensity indicates energy level
- **Advanced Particle Mechanics(to be implemented later):**
    - **Division:** High-energy particles can split into smaller particles
    - **Assembly:** Divided particles automatically reassemble after collision timer expires
    - **Different Forms:**
        - **Stone‑Particle (default):** Medium speed and zero energy consumption in the “withdrawal” state. It can only absorb energy through interacting with light beams.
        - Light-Particle? Heavy-Particle

**Wave Mode (Transformation State)**

- **Basic Properties:**
    - Constant energy reduction (rate determined by medium)
    - Can pass through solid walls (obstacle penetration)
    - Penetration width determined by energy level (amplitude)
    - Direction change capability
    - Visual feedback: Amplitude represents energy

### Transformation System

**Wave → Particle Transformation:**

- Wave function collapse into random possible particle forms
- Energy influences probability distribution
- Higher energy = more predictable outcome

**Particle → Wave Transformation:**

- Energy converts directly to wave amplitude
- Amplitude determines penetration capability

---

## **Blockers**

### 1. Normal Wall

- **Solution:** Wave form passes through
- **Cost:** Energy reduction based on wall thickness
- **Strategy:** Minimize time in wave form

### 2. Absorption Wall

- **Solution:** Particle collision or direction change
- **Challenge:** Wave form loses energy rapidly here
- **Strategy:** Use direction change find alternate path

### 3. Reflection Surface

- **Optimal Solution:** Particle form (predictable bounce)
- **Challenge:** Long width makes wave passage costly
- **Strategy:** Calculate angle for efficient traversal

### 4. Medium Zones

- **Example:** Blue zones (water medium)
- **Effect:** Wave travels faster than particle
- **Strategy:** Transform to wave for speed boost

## Enablers

### Energy Sources

- **Sun Beams:** Restore energy to particles
- **Light-emitting Buildings:** Passive energy restoration
- **Luminescent Plants:** Scattered energy pickups

---

## Game Flow

### **Core Loop**

1. **Default Particle state:** Run horizontally and accumulate or preserve energy.
2. **Obstacle appears:** Decide whether to stay particle or transform into a wave.
3. **Overcome obstacle**: Transform to wave**,** penetrate obstacles using amplitude; energy decreases.
4. **Collapsing:** When leaving wave form, revert to a (random) particle.
5. **Recharge:** Collect energy from beams to prepare for future obstacles.

### Win Condition

- **Primary:** Achieve high score (survival time)
- **Secondary:** Efficient puzzle solving (speed/energy optimization)

### Lose Condition

- Energy reaches zero
- Wave lacks energy to penetrate required obstacle
- Particle lacks energy for division after collision

---

## Visual and Audio Direction

### Visual Style

**Art Direction:** Minimalist game art with geometric abstraction

**Style References:**

- Mini Metro
- Sound Shapes

**Key Visual Elements:**

- Flat illustration techniques
- Simple shapes and lines
- Color as energy indicator

### Audio Style

*To be determined in next iteration*

---

## UI & Inputs

### HUD Elements

1. **Energy Bar:** Visual representation of current energy
2. **Score Display:** Time survived / distance traveled
3. **Form Indicator:** Current state (Particle/Wave)

### Controls

- **Default State:** No input = Particle form
- **Transform Key(F):** Hold to maintain Wave form
- **Release Key:** Return to Particle form
- **Arrow Keys**: Direction Control in wave form