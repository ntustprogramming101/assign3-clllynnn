// Platform Class: Represents a platform in the game
class Platform {
  float x, y, w = 80, h = 20; // Position and size of the platform
  float speed = 2; // moving speed of the platform


  Platform(float _x, float _y) {
    x = _x; // Set the initial x position
    y = _y; // Set the initial y position
  }

  void update() {
    // Stage 1-2: Move the platform up and reset its position when it goes out of view
    y -= speed;
    if (y < -h) {
      y = height;
      x = random(width - w);
    }
    // End of stage 1-2
  }

  void display() {
    image(platformImage, x, y, w, h); // Draw the platform image at its position
  }
}
