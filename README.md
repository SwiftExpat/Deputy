# Deputy

Delphi IDE expert providing integration of RunTime ToolKit, more information can be found here, https://swiftexpat.com/deputy.html.
Deputy was created using TOTAL https://github.com/DelphiWorlds/TOTAL

## License

Deputy is dual-licensed. You may choose to use it under the restrictions of the GPL v3 licence at no cost to you, or you may purchase a commercial license. 

## Terminate Running Processes

This expert will watch for compile and debug actions in the Delphi IDE and terminate any running instances of the target application before compile. Warning this will terminate the process without saving any data.

> Series 2.5 Release details

[![Release 2.5](https://img.youtube.com/vi/MWXR4M_sHkI/hqdefault.jpg)](https://youtu.be/MWXR4M_sHkI)

> Watch this video to see Deputy in action

[![Watch the video](https://img.youtube.com/vi/UfsSbDxbAL8/hqdefault.jpg)](https://youtu.be/UfsSbDxbAL8)

### Process Identification Logic

The plugin identifies process to kill in the following order:

1. Process that is a child of the IDE instance by PID and process name
2. Process by image path to ensure process killed is the one that would be overwritten by the IDE ( this allows you to have another copy running from a second directory ie your release build)

### Install Expert

https://swiftexpat.com/docs/doku.php?id=rttk:deputy:install

### Purpose

The IDE does not check before running a compile, it runs a few seconds of precompile then prompts that it can not overwrite the target.  This expert watches before that compile starts and clears out the old process to save me some seconds.


| Before                        | After                 |
| ------------------------------- | ----------------------- |
| Precompile                    | Expert clears process |
| prompt error                  | precompile            |
| User must close/ kill process | compile success       |
| compile success               |                       |

![Powered By Delphi](https://i1.wp.com/blogs.embarcadero.com/wp-content/uploads/2021/01/Powered-by-Delphi-white-175px-7388078.png?resize=175%2C82&ssl=1)  [Powered by Delphi](https://www.embarcadero.com/products/delphi)
