# Emotional Chatbot Interface in LÖVE2D

This is a visually expressive chatbot built using [LÖVE2D](https://love2d.org/). The bot responds to different emotional tones and input cues, simulates a natural typing delay, and displays dynamic animations like flying letters and slash effects for user input.

## 🧠 Features

- **Emotional NLP**: Detects emotion-based keywords like _sadness_, _hope_, _insults_, etc., and replies accordingly.
- **Typing Simulation**: Shows `.` → `..` → `...` typing states before the bot replies.
- **Dynamic Animations**:
  - Letters fly upward when typing.
  - Slash lines appear on backspace.
- **Modes**: Switches between `listen` and `vent` mode depending on context.
- **Personalization**: Responds differently if a name is detected.
- **Profile UI**: Includes a customizable chat header with name and profile image.


## 📦 Dependencies

- **LÖVE 11.x** or later
- All modules are Lua files and should be placed under a `phrasal/` directory.

## 🚀 Running the Project

1. Make sure you have [LÖVE](https://love2d.org/) installed.
2. Clone or download the repository.
3. Navigate to the project folder.
4. Run using:

```bash
love .
```
