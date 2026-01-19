# 🚀 Advanced Roblox Mechanics & Optimization

This repository showcases high-performance gameplay systems developed for the survival game **"Fading Blocks"**. Written in **Luau**, these modules focus on server optimization, precise hit detection, and responsive player movement.

## 🛠️ Key Systems

### 1. Volumetric Hit Detection (Spherecast vs. Raycast)
In fast-paced PvP scenarios, standard Raycasting often misses moving targets due to thin hitboxes ("needle effect").
* **Solution:** Implemented `workspace:Spherecast` to create a volumetric detection tunnel.
* **Result:** 100% hit accuracy on moving players without compromising server performance.
* **Feedback:** Added visual highlighting and sound queues for "Game Juice".

### 2. Hybrid Attribute Architecture (Data Optimization)
To prevent server lag caused by frequent Datastore calls (`GetAsync`), I designed a caching system using Roblox Attributes.
* **Logic:** `Player` loads data once -> Attributes are cached on the `Player` object -> Attributes are replicated to the `Character` on spawn.
* **Benefit:** Zero Datastore calls during gameplay/respawn, drastically reducing network overhead.

### 3. Logic-Based Double Jump
A robust state machine that prevents exploiting (infinite jumps).
* **Validation:** Uses strict Raycast checks to ensure the player initiates the first jump from a valid floor.
* **Chain Rule:** Validates `Jump -> Double Jump -> Land` cycle to prevent air-walking.

## 📂 File Structure

- `/src/Combat/PushSystem.lua`: The Spherecast implementation logic.
- `/src/Locomotion/DoubleJump.lua`: Client-side prediction and server validation for jumping.
- `/src/DataArchitecture/AttributeHandler.lua`: The backend logic for managing GamePass states.

## 💻 Tech Stack
- **Engine:** Roblox Studio
- **Language:** Luau (Type-checked Lua)
- **Tools:** Rojo, Git

---
*Developed by Mustafa | Solo Game Developer*
