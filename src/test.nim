import std/atomics,terminal,os,std/strutils


const
    rows = 3
    cols = 21
    frameRate:int =100
    jumpSpeed:int = 200
    scrollSpeed:int = 100
    collide:int = 0

var 
    grid: array[rows, array[cols, Atomic[int]]]
    jump: Atomic[int]
    score: Atomic[int]
    stop:Atomic[bool]

jump.store(0)
stop.store(false)

proc centerText(text: string, width: int): cstring =
    let spacehalf = (width div 2)
    let texthalf = (len(text) div 2)
    
    let totalPadding = spacehalf - texthalf
    let leftPadding = totalPadding
    let rightPadding = totalPadding + (width mod 2) - len(text)

    return ' '.repeat(leftPadding) & text

# Example usage:
echo centerText("Collided", 21)


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
        if stop.load() != true: 
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
        else:
            break

proc printGrid() =
    while true:
        if stop.load() != true: 
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
            sleep(frameRate)
        else:
            stdout.write("\x1b[3F")  
            stdout.write("\x1b[0J")
            echo "\x1b[31m",centerText("collided",21),"\x1b[0m"
            echo "\x1b[0G"
            echo "Score: ",score.load()
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
            break

proc scroll() =
    while true:
        if stop.load() != true: 
            for j in countdown(cols-1,0):
                if grid[2][j].load()==1:
                    stop.store(true)
                else:    
                    grid[2][j].store(2)
                    sleep(scrollSpeed)
                    grid[2][j].store(0)
                
                if j == 10:
                    score.store(score.load()+1)
        else:
            break



initGrid()


var
    inputThread: Thread[void]
    printThread: Thread[void]
    scrollThread: Thread[void]
    

createThread(inputThread, listenInput)
createThread(printThread, printGrid)
createThread(scrollThread, scroll)


joinThread(inputThread)
joinThread(printThread)
joinThread(scrollThread)
