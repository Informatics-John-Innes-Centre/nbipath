# NBI Paths Game

A command-line game to learn and practice `cd`, `pwd`, `ls`, absolute, and relative paths in a fun and interactive way.

---

## Disclaimer

**Warning:** The installation process will create a `/norwich` directory in your filesystem's root (`/`) along with subdirectories representing the NBI map. This is necessary for the game’s simulation of absolute paths.

If you are not comfortable with this, please review the `install.sh` and `creating_paths.sh` scripts before proceeding. An uninstallation script is provided to safely remove all created directories.

---

## Getting Started

### Prerequisites

* A Unix-like environment (Linux, macOS, or WSL on Windows).
* `bash` (version 4 or higher recommended).
* `sudo` access to run the installer.

> Optional: For best experience, ensure `readline` support is enabled in your Bash shell (for arrow keys and tab completion).

---

### Installation

1. Clone the repository or download the files.
2. Open your terminal and navigate to the project directory.
3. Run the installer with `sudo`:

```bash
sudo bash install.sh
```

This will:

* Make the game script executable.
* Create the required NBI directory map.
* Create a symbolic link at `/usr/local/bin/nbipath` so you can run the game from anywhere.

---

### Installation (Docker)

If you prefer running the game in a Docker container:

1. Ensure [Docker](https://www.docker.com/) is installed on your system.
2. Clone the repository:

```bash
git clone https://github.com/Informatics-John-Innes-Centre/nbipath.git
cd nbipath
```

3. Build the Docker image:

```bash
docker build -t nbipath:latest .
```

4. Run the game in a container:

```bash
docker run -it --rm nbipath:latest
```

To remove the Docker image later:

```bash
docker rmi nbipath:latest
```

## How to Play

Once installed, run:

```bash
nbipath
```

The game will then start:

1. Enter your username.
2. You will be placed in a random starting location within the NBI (Norwich Bioscience Institutes) map.
3. Follow the quest instructions to navigate to the target location. Use `cd` to move and `pwd`, `ls`, `tree`, or `help` to explore.
4. Each quest will indicate whether you should use an absolute or relative path.
5. Each quest starts with 10 points; points decrease by 1 for each incorrect or invalid command.
6. Complete all 10 quests to see your final score.

---

## Uninstallation

To remove the game and all its created files, run the uninstaller from the project directory with `sudo`:

```bash
sudo bash uninstall.sh
```

This will remove:

* The symbolic link `/usr/local/bin/nbipath`.
* The `/norwich` directory structure and all subdirectories created for the game.

---

## Features

* **Real-world map:** Based on Norwich Research Park, including the John Innes Centre (JIC), The Sainsbury Laboratory (TSL), Quadram Institute Bioscience (QIB), and Earlham Institute (EI).
* **Random quests:** 10 random quests per game, making each session unique.
* **Path type enforcement:** Forces absolute or relative paths for each quest.
* **Scoring system:** Points decrease with incorrect attempts.
* **Tab completion:** Auto-complete paths using the `Tab` key.
* **Command history:** Arrow-up/down to navigate previous commands.

---


## Author

This game was created by Miguel Gonzalez Sanchez.  
GitHub: [@cotximahou](https://github.com/cotximahou)


