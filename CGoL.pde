/* Conway's Game of Life
  A simple implementation of the Game of Life. The edges of the universe are considered
  barren here. Click to grant life to a cell and click again to remove it. The buttons
  are self-explanatory. The universe updates every quarter second, but this can be changed.
    Coded by Thomas Simmons, see license for details
*/


import java.util.Arrays;

// At the moment, the universe must be equal in all dimensions
final int cellsAcross = 50; // Number of cells on X axis, cannot go below 30
final int cellsDown = 50;   // Number of cells on Y axis, cannot go below 30
final int total = cellsAcross * cellsDown;

boolean[][] cells = new boolean[2][cellsAcross * cellsDown]; // Array to hold each cell, 1 or 0
int         living = 0;     // Count of living cells in the game
int         generation = 0; // The current generation of the universe
int         time = 0;       // Time var to determine how fast to proceed to the next generation
int         update = 250;   // The update period, default 250ms
PFont       f;

// Three buttons to control the program in the center of the window
Button start = new Button(((cellsAcross * 10)>>>1) - 140, (cellsDown * 10) + 3, 60, 24, "Start", color(0,255,0));
Button pause = new Button(((cellsAcross * 10)>>>1) - 30, (cellsDown * 10) + 3, 60, 24, "Pause", color(0,0,255));
Button reset = new Button(((cellsAcross * 10)>>>1) + 80, (cellsDown * 10) + 3, 60, 24, "Reset", color(255,0,0));

String mode = "setup"; // Can be "living" when running, "paused" when paused, or "setup" when initializing

// Call settings() first to comply with Processing 3.0 reqs
void settings()
{
    // Each cell is 10px tall and wide, +30 is for buttons
    size(cellsAcross * 10, (cellsDown * 10) + 30);
    smooth();
}

void setup()
{
    f = loadFont("Consolas-Bold-22.vlw");
    textFont(f, 14);
    textAlign(CENTER,CENTER);
    
    //Arrays.fill(cells[0], false);
    //Arrays.fill(cells[1], false);
    
    mode = "setup";
}


void draw()
{
    // Draw the grid and GUI
    drawBoard();
    
    // Draw every cell in the system
    int current = generation % 2; // The current set of cells in consideration
    for (int i=0; i < total; i++)
    {
        fill(0);
        if (cells[current][i])
        {
            int row = i / cellsDown;
            rect((i - (row * cellsAcross)) * 10, row * 10, 10, 10);
        }
    }
    
    // If the system is not paused, simulate life every update period
    if (mode == "living" && (millis() - time > update))
    {
        simulateLife();
        System.out.println(living + " " + generation);
        time = millis();
    }
    
}

void mousePressed()
{
    if (mode == "setup" && mouseY <= cellsDown*10)
    {
        int newCell = (mouseY / 10) * cellsAcross;
        newCell += mouseX / 10;
        if (cells[0][newCell])
        {
            cells[0][newCell] = false;
            living--;
        }
        else
        {
            cells[0][newCell] = true;
            living++;
        }
    }
    else if (reset.collDetect())
    {
        living = 0;
        generation = 0;
        Arrays.fill(cells[0], false);
        Arrays.fill(cells[1], false);
        mode = "setup";
    }
    else if (start.collDetect() && mode != "living")
    {
        time = millis();
        mode = "living";
    }
    else if (pause.collDetect())
    {
        mode = "paused";
    }
}


// Simulate life on the board
void simulateLife()
{
    int curGen  = generation % 2;       // The set of cells from which we sum neighbors
    int nextGen = (curGen + 1) % 2;     // The set of cells we will populate as per the rules
    
    // For this implementation, edges are considered barren [i.e. life stops there]
    for (int i = 0; i < total; i++)
    {
        char n = 0; // Number of neighbors
        // Sum all cells in the current cell's Moore neighborhood
        
        if (!(i < cellsAcross))                            // Cell is not in top row
        {
            n += (cells[curGen][i-cellsAcross]) ? 1 : 0;                                       // Top-middle
            if (!(i%cellsAcross == 0))                     // Cell is not on far left
            {
                n += (cells[curGen][i-1]) ? 1 : 0;                                             // Left
                n += (cells[curGen][i-cellsAcross-1]) ? 1 : 0;                                 // Top-left
                if (!(i >= total - cellsAcross))           // Cell is not in bottom row
                {
                    n += (cells[curGen][i+cellsAcross]) ? 1 : 0;                               // Bottom-middle
                    n += (cells[curGen][i+cellsAcross-1]) ? 1 : 0;                             // Bottom-left
                    if (!(i%cellsAcross == cellsAcross-1)) // Cell is not on far right
                    {
                        n += (cells[curGen][i-cellsAcross+1]) ? 1 : 0;                         // Top-right
                        n += (cells[curGen][i+1]) ? 1 : 0;                                     // Right
                        n += (cells[curGen][i+cellsAcross+1]) ? 1 : 0;                         // Bottom-right
                    }
                }
                else // Cell is on bottom
                {
                    if (!(i%cellsAcross == cellsAcross-1)) // Cell is not on far right
                    {
                        n += (cells[curGen][i-cellsAcross+1]) ? 1 : 0;                         // Top-right
                        n += (cells[curGen][i+1]) ? 1 : 0;                                     // Right
                    }
                }
            }
            else    // Cell is on far left
            {
                n += (cells[curGen][i-cellsAcross+1]) ? 1 : 0;                                 // Top-right
                n += (cells[curGen][i+1]) ? 1 : 0;                                             // Right
                if (!(i >= total - cellsAcross))           // Cell is not in bottom row
                {
                    n += (cells[curGen][i+cellsAcross]) ? 1 : 0;                               // Bottom-middle
                    n += (cells[curGen][i+cellsAcross+1]) ? 1 : 0;                             // Bottom-right
                }
            }
        }
        else                                               // Cell is in top row
        {
            n += (cells[curGen][i+cellsAcross]) ? 1 : 0;                                       // Bottom-middle
            if (!(i%cellsAcross == 0))                     // Cell is not on far left
            {
                n += (cells[curGen][i-1]) ? 1 : 0;                                             // Left
                n += (cells[curGen][i+cellsAcross-1]) ? 1 : 0;                                 // Bottom-left
                if (!(i%cellsAcross == cellsAcross-1))     // Cell is not on far right
                {
                    n += (cells[curGen][i+1]) ? 1 : 0;                                         // Right
                    n += (cells[curGen][i+cellsAcross+1]) ? 1 : 0;                             // Bottom-right
                }
            }
            else                                          // Cell is on far left
            {
                n += (cells[curGen][i+1]) ? 1 : 0;                                             // Right
                n += (cells[curGen][i+cellsAcross+1]) ? 1 : 0;                                 // Bottom-right
            }
        }
        
        
        // Determine if the cell is alive or dead where barren sites produce life where n=3
        //  and living cells continue life if n=2,3
        if (cells[curGen][i] && (n == 2 || n == 3)) cells[nextGen][i] = true;    // Cell continues living
        else if (cells[curGen][i]) { cells[nextGen][i] = false; living--; }      // Cell has died
        else cells[nextGen][i] = false;;                                         // Area still barren
        
        if (!cells[curGen][i] && n == 3) { cells[nextGen][i] = true; living++; } // Where once there was nothing, life!
    }
    
    generation++;
}

// Puts the grid and GUI on screen
void drawBoard()
{
    background(255);
    // Draw the grid system, the height-30 is to leave space for GUI
    for (int i=10; i < height-20; i+=10) line(0, i, width, i);
    for (int i=10; i < width; i+=10) line(i, 0, i, height-30);
    // Draw buttons
    start.drawMe();
    pause.drawMe();
    reset.drawMe();
}


// A class for a button for user input
class Button
{
    // A button for user input
    int x, y;
    int w, h;
    String buttonText; // For different types: Replay, Continue, Quit
    color buttonFill;
    int bCenterX;
    int bCenterY;
    
    Button(int ix, int iy, int iw, int ih, String btext, color c)
    {
        x = ix;
        y = iy;
        w = iw;
        h = ih;
        buttonText = btext;
        buttonFill = c;
        bCenterX = x + (w / 2);
        bCenterY = y + (h / 2);
    }
    
    void drawMe()
    {
        fill(buttonFill);
        rect(x, y, w, h);
        fill(0);
        rect(x+5, y+5, w-10, h-10);
        fill(255);
        text(buttonText, bCenterX, bCenterY);
    }
    
    boolean collDetect()
    {
        if (mouseX >= x && mouseX <= (x+w) && mouseY >= y && mouseY <= (y+h))
        {
            return true;
        }
        return false;
    }
}
