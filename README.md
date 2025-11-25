# Stampy
Stampy is very basic Windows application to track your working hours.<br>
The data is recorded locally only.

![Stampy normal mode](docs/images/Stampy_main.png)

## Simple mode

In simple mode only the necessary buttons to change your working state are displayed.

![Stampy simple mode](docs/images/Stampy_simple.png)

When the window gets closed in simple mode, the application wont stop but minimize into tray.<br>
Hovering the mouse over the tray icon will display status, work time and pause time of the current day.

![Stampy tray icon with statistics](docs/images/Stampy_tray.png)

Also, right clicking the Stampy tray icon will open a context menu which lets you record a start, stop or pause. 

## Editing and deleting entries
Via right clicking an entry in the time table it can be changed or deleted.<br>
The displayed day can be switched through by the up/down arrows next to the date string.

![Stampy time table context menu](docs/images/Stampy_context.png)
![Stampy change entry window](docs/images/Stampy_change.png)

## Work time analysis
On tab `Time Domain Analysis` an analysis of the recorded work time can be performed for a week or a month.<br>
Week or month can be switched through by the up/down arrows next to `Count:`.<br>
The calculations will use the configured options on the `Options` tab to evaluate your worked hours, your quota and the difference of those two (that is overtime or missing hours).

![Stampy analysis](docs/images/Stampy_analysis.png)
![Stampy options](docs/images/Stampy_options.png)