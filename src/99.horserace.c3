// Program: Horse Race
// Description: A horse race 'game' for the terminal in C3.
// YouTube Lesson: https://www.youtube.com/watch?v=I8mZ5m-6TF0
// Author: Kevin Browne @ https://portfoliocourses.com


import std::io;
import std::math::random;
import std::time;
import std::thread;
  
const int NUM_HORSES = 8;
const int TRACK_LENGTH = 40;

fn void print_race(int[] positions)
{
    for (int i = 0; i < NUM_HORSES; i++)
    {
        io::printf("|");
        for (int j = 0; j < TRACK_LENGTH; j++)
        {
            if (j == positions[i]) io::printf("🐎");
            else io::printf("-");
        }
        io::printf("| (Horse %d)\n", i + 1);
    }

    io::stdout().fflush(); 
}

fn int main()
{
    int[NUM_HORSES] positions;
    int winner;

    int[NUM_HORSES] winners;
    int total_winners = 0;

    long now = (long)(time::now().to_seconds() * 1000.0)
    random::srand(now);

    for (int i = 0; i < NUM_HORSES; i++)
    {
        positions[i] = TRACK_LENGTH - 1;
    }

    print_race(positions);
    
    while (total_winners == 0)
    {
        for (int i = 0; i < NUM_HORSES; i++)
        {
            positions[i] -= randome::rand() % 3; 

            if (positions[i] <= 0)
            {
                positions[i] = 0;
                winners[total_winners] = i;
                total_winners++;
            }
        }

        thread::sleep_ms(200);
        
        io::printf("\033[%dA", NUM_HORSES);

        print_race(positions);    
    }

    winner = winners[ random::rand() % total_winners ];
    
    printf("\n🏆 Horse %d wins the race!\n", winner + 1);

    return 0;
}