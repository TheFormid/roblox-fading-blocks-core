# 🚀 Advanced Roblox Mechanics & Optimization

> **High-performance gameplay systems developed for "Fading Blocks" (Roblox/Luau).**
> Focuses on server optimization, precise hit detection (Spherecast), and robust state machines.

---

## 🛠️ Key Systems

### 1. Volumetric Hit Detection (Spherecast vs. Raycast)
In fast-paced PvP scenarios, standard Raycasting often misses moving targets due to thin hitboxes ("needle effect").
* **Solution:** Implemented `workspace:Spherecast` to create a volumetric detection tunnel.
* **Result:** 100% hit accuracy on moving players without compromising server performance.
* **Feedback:** Added visual highlighting and sound queues for "Game Juice".

### 2. Hybrid Attribute Architecture (Data Optimization)
To prevent server lag caused by frequent Datastore calls (`GetAsync`), I designed a caching system using Roblox Attributes.

```mermaid
graph TD
    A[Player Joins] -->|Checks Datastore Once| B(Server Script)
    B -->|Stamps Attribute| C{Player Object RAM}
    C -- "HasPush: true" --> D[Character Spawns]
    D -->|Replicates Attribute| E(Character Model)
    E -->|Client Reads Attribute| F[Enable Push Tool]
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style F fill:#ccf,stroke:#333,stroke-width:2px

Logic: Player loads data once -> Attributes are cached on the Player object (RAM) -> Attributes are replicated to the Character automatically on spawn.

Benefit: Zero Datastore calls during gameplay/respawn, drastically reducing network overhead.

3. Logic-Based Double Jump
A robust state machine that prevents exploiting (infinite jumps).

Validation: Uses strict checks to ensure the player initiates the first jump from a valid floor.

Chain Rule: Validates Jump -> Double Jump -> Land cycle to prevent air-walking.

Optimization: Uses object pooling for visual particles to reduce garbage collection.

📂 Source Code Access
Click on the files below to view the optimized Luau implementation:

🦵 Locomotion
📄 DoubleJump.lua - Client-side state machine & pooled visual effects.

⚔️ Combat
📄 PushSystem_Client.lua - Volumetric Spherecast implementation & feedback.

💾 Data & Server
📄 HybridAttributeHandler.lua - Server-side Attribute caching & replication logic.

💻 Tech Stack
Engine: Roblox Studio

Language: Luau (Type-checked Lua)

Patterns: State Machine, Object Pooling, Attribute Caching

Tools: Rojo, Git

Developed by Mustafa | Solo Game Developer
