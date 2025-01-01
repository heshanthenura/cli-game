import std/atomics,terminal,os


const
    rows = 3
    cols = 21
    jumpSpeed:int = 200
    scrollSpeed:int = 100
    collide:int = 0

var 
    grid: array[rows, array[cols, Atomic[int]]]
    jump: Atomic[int]

jump.store(0)

proc initGrid() =
    for i in 0..<rows:
        for j in 0..<cols:
            grid[i][j].store(0)
    grid[2][10].store(1)
    # grid[2][20].store(2)

proc jumpPlayer() =
    grid[0][10].store(0)
    grid[1][10].store(1)
    grid[2][10].store(0)
    sleep(jumpSpeed)
    grid[0][10].store(1)
    grid[1][10].store(0)
    grid[2][10].store(0)
    sleep(jumpSpeed)
    grid[0][10].store(0)
    grid[1][10].store(1)
    grid[2][10].store(0)
    sleep(jumpSpeed)
    grid[0][10].store(0)
    grid[1][10].store(0)
    grid[2][10].store(1)

proc listenInput() =
    while true:
        case getch():
        of ' ':
            if jump.load() == 0:
                jump.store(1)
                var jumpThread: Thread[void]
                createThread(jumpThread, jumpPlayer)  
                jump.store(0)
        of 'q':
            echo "Goodbye!"
            quit(0)
        else:
            echo "Invalid choice; bye"
            quit(1)

proc printGrid() =
    while true:
        stdout.write("\x1b[3F")  
        stdout.write("\x1b[0J")  
        for i in 0..<rows:
            for j in 0..<cols:
                # stdout.write($grid[i][j].load() & " ")
                if grid[i][j].load() == 0: 
                    # stdout.write("0")
                    stdout.write(" ")
                    # echo "\x1b[0G" 
                elif grid[i][j].load() == 2:
                    stdout.write("⛝")
                else:
                    stdout.write("•")
                    # stdout.write("1")
                stdout.flushFile()
            echo "\x1b[0G" 

        sleep(33)

proc scroll() =
    while true:
        for j in countdown(cols-1,0):
            grid[2][j].store(2)
            sleep(scrollSpeed)
            grid[2][j].store(0)

proc collision() =
  if (grid[0][10].load() != 1 and grid[1][10].load() != 1 and grid[2][10].load() != 1):
    quit(1)
    echo "collide"
    echo "collide"
    echo "collide"
    echo "collide"
    echo "collide"
    echo "collide"


initGrid()

var
    inputThread: Thread[void]
    printThread: Thread[void]
    scrollThread: Thread[void]
    collisionThread: Thread[void]

createThread(inputThread, listenInput)
createThread(printThread, printGrid)
createThread(scrollThread, scroll)
createThread(collisionThread, collision)

joinThread(inputThread)
joinThread(printThread)
joinThread(scrollThread)
joinThread(collisionThread)