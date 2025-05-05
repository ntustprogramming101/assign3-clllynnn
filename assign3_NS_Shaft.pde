// Constants
final int NUM_PLATFORMS = 10; // Number of platforms
final int PLAYER_HEALTH = 3; // Player's health
final float SCROLL_SPEED = -2; // Speed of the background scrolling
final int INVINCIBILITY_DURATION = 180; // invisible for 3 seconds at 60 FPS
final int DAMAGE_BLINK_DURATION = 30; // blink for 0.5 seconds at 60 FPS
final int ANIMATION_INTERVAL = 10; // Frames per animation
final int FRAME_RATE = 60; // Target frame rate
final int WIN_MINIMUM_TIME = 60; // Time in seconds required to win
final float SLIDE_SPEED = 5; // Speed at which the win image slides in
final int GAME_RUN = 0, GAME_WIN = 1, GAME_OVER = 2; // Game states

// Game Variables
Platform[] platforms = new Platform[NUM_PLATFORMS]; // Array to store all platforms
Player player; // The player object
PImage[][] playerSprites = new PImage[3][]; // Array to store player sprites
// 1st[]: sprite index (0=idle, 1=left, 2=right) ; 2nd[]: animated frame index
float bgY1 = 0, bgY2; // Vertical positions of the two background images for scrolling
PImage bg; // Background image
PImage platformImage; // Images for platforms
PImage winImage; // The image displayed when the player wins
float winImageY; // The vertical position of the win image
float winImageHeight; // The height of the win image
int survivalTime = 0; // Time the player has survived in seconds
int frameCounter = 0; // Counter to track frames for timing purposes
int gameState; // Current game state

// Setup
void setup() {
  size(400, 600);
  frameRate(FRAME_RATE); // Set the frame rate
  loadAssets();
  initializeGame();
}

void loadAssets() {
  bg = loadImage("background.png");
  bg.resize(width, height); // Resize the background image to fit the screen
  bgY2 = -height; // Second background image starts off-screen
  platformImage = loadImage("cloud.png");
  winImage = loadImage("win_image.png"); // Load the win image
  winImage.resize(width, 0); // Resize the win image to fit the screen width
  winImageHeight = winImage.height; // Get the height of the win image
  winImageY = height; // set the win image off-screen

  // Initialize the playerSprites array with subarrays for different movement states
  playerSprites[0] = new PImage[1]; // idle state (1 frame)
  playerSprites[1] = new PImage[2]; // moving left (2 frames for animation)
  playerSprites[2] = new PImage[2]; // moving right (2 frames for animation)

  // Load the sprite images for each movement state
  playerSprites[0][0] = loadImage("idle.png"); // Idle sprite
  playerSprites[1][0] = loadImage("move_left1.png"); // First frame of moving left
  playerSprites[1][1] = loadImage("move_left2.png"); // Second frame of moving left
  playerSprites[2][0] = loadImage("move_right1.png"); // First frame of moving right
  playerSprites[2][1] = loadImage("move_right2.png"); // Second frame of moving right
}

void initializeGame() {
  player = new Player();
  initializePlatforms();
  survivalTime = 0;
  frameCounter = 0;
  gameState = GAME_RUN; // Set the initial game state to running
  winImageY = height; // Start the win image off-screen
}

void initializePlatforms() {
  // stage 1-1: generate 10 platforms with random positions on the screen
  for (int i = 0; i < NUM_PLATFORMS; i++) {
    // you need to change this line to create a new platform object with random horizontal positions, while distributed evenly in vertical space
    float platformX = random(width - 80);
    float platformY = height / NUM_PLATFORMS * i;
    platforms[i] = new Platform(platformX, platformY);
  }
  // End of stage 1-1
}

// Main Game Loop
void draw() {
  scrollBackground(); // Scroll the background continuously

  switch (gameState) {
  case GAME_RUN:
    runGame();
    break;
  case GAME_WIN:
    winGame();
    break;
  case GAME_OVER:
    endGame();
    break;
  }
}

void runGame() {
  for (Platform platform : platforms) {
    platform.update(); // Update the platform's position
    platform.display(); // Display the platform on the screen
  }

  player.update(); // Update the player's position and state
  player.display(); // Display the player on the screen

  frameCounter++;
  if (frameCounter % FRAME_RATE == 0) {
    survivalTime++; // Increment survival time every second
  }

  displayHealthAndTimer(); // Display the player's health and survival time


  if (player.health <= 0) { // check if gameover (player is dead)
    gameState = GAME_OVER;  // Set the game state to game over
  }

  if (survivalTime >= WIN_MINIMUM_TIME) { // Check if the player has survived long enough to win
    gameState = GAME_WIN; // Set the game state to win
  }
}

// Background Scrolling
void scrollBackground() {
  image(bg, 0, bgY1); // Draw the first background image
  image(bg, 0, bgY2); // Draw the second background image

  bgY1 += SCROLL_SPEED; // Move the first background image up
  bgY2 += SCROLL_SPEED; // Move the second background image up

  // Reset the background positions when they scroll out of view
  if (bgY1 <= -bg.height) bgY1 = bgY2 + bg.height;
  if (bgY2 <= -bg.height) bgY2 = bgY1 + bg.height;
}

// Display Functions
void displayHealthAndTimer() {
  fill(0);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Health: " + player.health, 10, 20); // Display health
  text("Time: " + survivalTime + " s", 10, 40); // Display survival time
}

// Handles the win condition
void winGame() {
  displayWinImage(); // Show the win image
  displayWinMessage(); // Show a congratulatory message
}

// Handles the end of the game
void endGame() {
  player.forceDropToBottom(); // Allow the player to drop to the bottom of the screen
  displayGameOver(); // Show a game-over message if the player has lost
}

// Win Image Functions
void displayWinImage() {
  if (winImageY > height - winImageHeight) {
    winImageY -= SLIDE_SPEED;
  } else {
    winImageY = height - winImageHeight; // Stop at the bottom of the screen
  }
  image(winImage, 0, winImageY, width, winImageHeight); // Displays the win image at its current position
}



// Displays a game-over message when the player loses
void displayGameOver() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 0, 0);
  text("Game Over", width / 2, height / 2 - 20);

  textSize(16);
  fill(0);
  text("You survived: " + survivalTime + " seconds", width / 2, height / 2 + 20);
  text("Press R to restart", width / 2, height / 2 + 40);
}

// Displays a congratulatory message when the player wins
void displayWinMessage() {
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(0, 255, 0);
  text("Congratulations!", width / 2, height / 2 - 20);

  textSize(16);
  fill(0);
  text("You survived: " + survivalTime + " seconds", width / 2, height / 2 + 20);
  text("Press R to restart", width / 2, height / 2 + 40);
}

// Input Handling
// Stage 2-1: Handle horizontal movement based on moveDir, which is set by keyPressed and keyReleased
void keyPressed() {
  if (key == 'a' || key == 'A') {
    // Move left, call player.setMovement() to set the moveDir
    player.setMovement(-1);
  } else if (key == 'd' || key == 'D') {
    // Move right, call player.setMovement() to set the moveDir
    player.setMovement(1);
  } else if (key == 'r' || key == 'R') {
    restartGame();
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || key == 'd' || key == 'D') {
    // Stop moving, call player.setMovement() to set the moveDir
    player.setMovement(0);
  }
}
// End of stage 2-1

void restartGame() {
  initializeGame();
}
