import argparse
from shutil import move
import signal
import time

import pyautogui
import readchar


def handler(signum, frame):
    msg = "Ctrl-c was pressed. Do you really want to exit? y/n "
    print(msg, end="", flush=True)
    res = readchar.readchar()
    if res == 'y':
        print("")
        exit(1)
    else:
        print("", end="\r", flush=True)
        print(" " * len(msg), end="", flush=True) # clear the printed line
        print("    ", end="\r", flush=True)


signal.signal(signal.SIGINT, handler)

def jiggle(move_offset: int, duration: float, multiplier: float):
    print("jiggle")
    if multiplier > 1:
        move_offset = move_offset*multiplier
        duration = duration*multiplier

    try:
        pyautogui.moveRel(move_offset, -move_offset, duration=duration)
        pyautogui.moveRel(-move_offset, move_offset, duration=duration)
        pyautogui.moveRel(move_offset, -move_offset, duration=duration)
        pyautogui.moveRel(-move_offset, move_offset, duration=duration)
    except pyautogui.FailSafeException:
        print("unable to jiggle")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--move-offset", type=int, help="The move offset of the jiggle", default=1)
    parser.add_argument("-d", "--duration", type=float, help="The duration of each move - there are two", default=0.01)
    parser.add_argument("-i", "--initial-timeout", type=int, help="The initial wait before any jiggle occurs", default=10)
    parser.add_argument("-s", "--sleep-duration", type=float, help="Time in seconds between each jiggle", default=1)
    args = parser.parse_args()

    multiplier = 0

    current_state = None
    while True:
        if current_state is None:
            current_state = pyautogui.position()
            print('init timeout')
            time.sleep(args.initial_timeout)
        else:
            if current_state == pyautogui.position():
                multiplier += 1
                jiggle(args.move_offset, args.duration, multiplier)
                current_state = pyautogui.position()
            else:
                print('movement clearing current state')
                multiplier = 0
                current_state = None

        time.sleep(args.sleep_duration)

