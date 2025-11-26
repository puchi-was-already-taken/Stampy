# Stampy

Stampy is a very basic, portable Windows application to track your working hours.<br>
All your data is stored locally!

![Stampy normal mode](docs/images/Stampy_main.png)

## Simple Mode

In Simple Mode only the necessary buttons to change your working state are displayed.

![Stampy simple mode](docs/images/Stampy_simple.png)

When the window is closed in Simple Mode, the application **won't** stop but it **minimizes** into the system tray.<br>
Hovering the mouse over the tray icon will display the status, work time and pause time for the current day.

![Stampy tray icon with statistics](docs/images/Stampy_tray.png)

Additionally, right-clicking the Stampy tray icon will open a context menu allowing you to record a start, stop or pause.

![Stampy tray context menu](docs/images/Stampy_context_tray.png)

## Editing and Deleting Entries
You can edit or delete an entry by right-clicking it in the timetable.<br>
The displayed day can be changed using the arrow buttons next to the date or by directly entering an offset relative to the current day.

![Stampy time table context menu](docs/images/Stampy_context.png)
![Stampy change entry window](docs/images/Stampy_change.png)

## Work Time Analysis
The `Work Time Analysis` tab allows you to analyze the recorded working time on a weekly or monthly basis.
The number of weeks or months to analyze can be specified using the arrow buttons next to `Count` or by directly editing that number.
The calculations use the configured options on the `Options` tab to determine your working hours, your quota and the difference between those two values (i.e. overtime or missing hours).

![Stampy analysis](docs/images/Stampy_analysis.png)
![Stampy options](docs/images/Stampy_options.png)