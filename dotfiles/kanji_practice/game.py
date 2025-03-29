# A game I made to learn kanji
import random
import os
import time
import subprocess
from collections import deque

GREEN = "\033[92m"
RED = "\033[91m"
RESET = "\033[0m"


def print_colored(text, color):
    print(f"{color}{text}{RESET}")


def parse_kanji_file(filepath):
    kanji_list = []
    with open(filepath, "r", encoding="utf-8") as file:
        for line in file:
            parts = line.strip().split()
            if len(parts) >= 3:
                kanji = parts[0]
                romaji = parts[1]
                meaning = " ".join(parts[2:])
                kanji_list.append((kanji, romaji, meaning))
    return kanji_list


def create_kanji_sections(kanji_list, group_size=50):
    return [
        kanji_list[i : i + group_size] for i in range(0, len(kanji_list), group_size)
    ]


def clear_screen():
    time.sleep(1)
    os.system("cls" if os.name == "nt" else "clear")
    return


def show_image():
    imgExtension = ["png", "jpeg", "jpg"]
    allImages = list()
    for img in os.listdir("imgs/"):
        ext = img.split(".")[len(img.split(".")) - 1]
        if ext in imgExtension:
            allImages.append(img)
    choice = random.randint(0, len(allImages) - 1)
    chosenImage = allImages[choice]
    subprocess.run(
        ["fim", f"imgs/{chosenImage}", "-r", "1000:2800", "-q", "-c", "sleep 70; quit"],
        capture_output=True,
        text=True,
    )
    return


def study_kanji(kanji_list, section, total_sections):
    total_count = 0
    correct_count = 0
    clear_screen_count = 0
    # Use deque to keep track of last 100 attempts
    last_hundred = deque(maxlen=100)

    while True:
        kanji, romaji, translation = random.choice(kanji_list)
        if clear_screen_count % 5 == 0 and clear_screen_count > 0:
            clear_screen()
        if clear_screen_count % 35 == 0 and clear_screen_count > 0:
            print(f"Current section: {section}/{total_sections}")
            print(f"Total Score: {correct_count}/{total_count}")
            if len(last_hundred) == 100:
                success_rate = sum(last_hundred) / 100
                print(f"Last 100 attempts success rate: {success_rate:.2%}")
                if success_rate >= 0.8 and section < total_sections:
                    print_colored("Congratulations! Moving to next section!", GREEN)
                    time.sleep(2)
                    return "next_section"

        print(f"{kanji}")
        while True:
            user_input = input().strip().lower()
            if user_input == "a":
                print_colored(f"{romaji} - {translation}", GREEN)
                total_count += 1
                clear_screen_count += 1
                last_hundred.append(0)
                break
            elif user_input == "q":
                return "quit"
            elif user_input == "r":
                return "restart"
            elif user_input == romaji:
                print_colored(f"{kanji} - {translation}", GREEN)
                correct_count += 1
                total_count += 1
                clear_screen_count += 1
                last_hundred.append(1)
                break
            else:
                total_count += 1
                print_colored(f"{kanji}", RED)
                last_hundred.append(0)


def main():
    while True:
        filename = "/home/nixos/.config/nixos/dotfiles/kanji_practice/kanjis.txt"
        kanji_list = parse_kanji_file(filename)
        kanji_sections = create_kanji_sections(kanji_list)
        print("Welcome to the Japanese Kanji Study Program!")
        print("'a' - answer, 'r' - restart, 'q' - quit")

        current_section = int(
            input(
                f"Found {len(kanji_list)} kanjis. Enter a section number (1-{len(kanji_sections)}): "
            )
        )

        while current_section <= len(kanji_sections):
            selected_group = kanji_sections[current_section - 1]
            result = study_kanji(selected_group, current_section, len(kanji_sections))

            if result == "quit":
                return
            elif result == "restart":
                clear_screen()
                break  # Break the inner loop to allow new section selection
            elif result == "next_section":
                clear_screen()
                current_section += 1
                if current_section > len(kanji_sections):
                    print_colored(
                        "Congratulations! You've completed all sections!", GREEN
                    )
                    time.sleep(2)
                    break
                continue


if __name__ == "__main__":
    main()
