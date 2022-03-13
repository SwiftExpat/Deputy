# Deputy

Delphi IDE plugin

Depends on TOTAL https://github.com/DelphiWorlds/TOTAL

## Terminate Running

This expert will watch for compile and debug actions in the Delphi IDE and terminate any running instances of the target application before compile. Warning this will terminate the process without saving any data.

### Process Identification Logic

The plugin identifies process to kill in the following order:

1. Process that is a child of the IDE instance by PID and process name
2. Process by image path to ensure process killed is the one that would be overwritten by the IDE ( this allows you to have another copy running from a second directory ie your release build)
