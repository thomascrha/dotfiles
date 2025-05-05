#!/usr/bin/env python3
"""
Timesheet Parser

This script parses timesheet approval files and organizes the data by task,
showing all dates when each task was performed.
"""

import os
import re
import argparse
from collections import defaultdict
from datetime import datetime
from rich import print


def parse_timesheet_file(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as file:
        content = file.read()

    data_section = re.search(r'Date\s+Hours Worked\s+Tasks\n(.*?)Total Hours',
                            content, re.DOTALL)

    if not data_section:
        raise RuntimeError(f"Unable to parse the data section of {file_path}")

    entries = defaultdict(list)
    lines = data_section.group(1).strip().split('\n')

    for line in lines:
        # Match the pattern: Day, DD Mon YYYY   hours   task
        match = re.match(r'([A-Za-z]+, \d+ [A-Za-z]+ \d+)\s+(\d+|0)\s+(.*)', line.strip())
        if match:
            date_str, hours, task = match.groups()
            try:
                # Parse the date string
                date_obj = datetime.strptime(date_str, "%a, %d %b %Y")
                date_formatted = date_obj.strftime("%Y-%m-%d")
                day_of_week = date_obj.strftime("%A")
                task = task.strip().lower()

                entries[task].append({
                    'date': date_formatted,
                    'day_of_week': day_of_week,
                    'hours': int(hours)
                })
            except ValueError:
                raise ValueError(f"Warning: Failed to parse date '{date_str}' in {file_path}")

    return entries


def process_folder(folder_path):
    combined_entries = defaultdict(list)

    for filename in os.listdir(folder_path):
        if filename.endswith('.txt'):
            file_path = os.path.join(folder_path, filename)
            file_entries = parse_timesheet_file(file_path)

            for task, task_entries in file_entries.items():
                combined_entries[task].extend(task_entries)

    for task in combined_entries:
        combined_entries[task].sort(key=lambda x: x['date'])

    return combined_entries

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse timesheet approval files.')
    parser.add_argument('folder', help='Folder containing timesheet approval files')
    args = parser.parse_args()

    tasks  = process_folder(args.folder)

    print(f"\nTimesheet Summary\n{'-' * 50}")
    print("\nDetailed Task Breakdown:")
    total_hours = 0
    for task_name, entries in sorted(tasks.items()):
        task_hours = sum(entry['hours'] for entry in entries)
        total_hours += task_hours
        print(f"\nTask: {task_name}")
        task_days = len(entries)  # Count of unique entries for this task
        print(f"Total Hours: {task_hours} | Total Days: {task_days}")
        print("Entries:")
        for entry in entries:
            print(f"  - {entry['date']} ({entry['day_of_week']}): {entry['hours']} hours")

    print(f"\n{'-' * 50}")
    print(f"Total Hours: {total_hours}")

