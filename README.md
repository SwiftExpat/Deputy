![Top language](https://img.shields.io/github/languages/top/SwiftExpat/Deputy)
[![GitHub release](https://img.shields.io/github/release/SwiftExpat/Deputy)](https://github.com/SwiftExpat/Deputy/release)
[![GitHub issues](https://img.shields.io/github/issues/SwiftExpat/Deputy)](https://github.com/SwiftExpat/Deputy/issues)
[![GitHub PR](https://img.shields.io/github/issues-pr/SwiftExpat/Deputy)](https://github.com/SwiftExpat/Deputy/pulls)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/SwiftExpat/Deputy)
![GitHub last commit](https://img.shields.io/github/last-commit/SwiftExpat/Deputy)

# Deputy

Delphi IDE expert providing integration of RunTime ToolKit, more information can be found here, https://swiftexpat.com/deputy.html.
Deputy was created using TOTAL https://github.com/DelphiWorlds/TOTAL

## License

Deputy is dual-licensed. Options are: 
1. Choose to use it under the restrictions of the GPL v3 licence at no cost to you.
2. Purchase a commercial license with support for 1 year at https://swiftexpat.com/deputy.html. 

## Install Expert

[Install / Uninstall instructions](https://github.com/SwiftExpat/Deputy/wiki/Deputy-Install---UnInstall)

## Process Manager

Process Manager will montior compile and debug actions in the Delphi IDE and terminate any running instances of the target application before compile. Options are to terminate the process without saving any data or close and handle the memory leak.

> Series 2.6 Release details

[![Release 2.6 Process Manager](https://img.youtube.com/vi/j7EdJcQSELY/hqdefault.jpg)](https://youtu.be/j7EdJcQSELY)  

### Process Identification Logic

The plugin identifies process to kill in the following order:

1. Process that is a child of the IDE instance by PID and process name
2. Process by image path to ensure process killed is the one that would be overwritten by the IDE ( this allows you to have another copy running from a second directory ie your release build)

### Purpose

The IDE does not check before running a compile, it runs a few seconds of precompile then prompts that it can not overwrite the target.  This expert watches before that compile starts and clears out the old process to save me some seconds.

## Instance Manager

Instance Manager prevents multiple versions of the Delphi IDE from running at the same time.

> Series 2.6 Release details

[![Release 2.6 Instance Manager](https://img.youtube.com/vi/xIgnnfIDA2k/hqdefault.jpg)](https://youtu.be/xIgnnfIDA2k)

![Powered By Delphi](https://i1.wp.com/blogs.embarcadero.com/wp-content/uploads/2021/01/Powered-by-Delphi-white-175px-7388078.png?resize=175%2C82&ssl=1)  [Powered by Delphi](https://www.embarcadero.com/products/delphi)
