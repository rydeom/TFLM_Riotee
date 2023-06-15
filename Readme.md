# Riotee SDK template project

This is a template project for developing an application for a battery-free Riotee device.
The Makefile-based project optionally supports Visual Studio Code.

## Usage

Follow the instructions to install the Riotee SDK and its dependencies to a location on your computer.

Next, click on the green `Use this template` button on this repository's GitHub page to create your own repository from this template.
Give your repository a name, for example, `my-riotee-app`.
Clone your new repository using its URL.

```shell
git clone git@github.com:yourusername/my-riotee-app.git
```
### Command-line

If you're using Visual Studio Code for development you can skip this step.

If you want to build the project from the commandline or some other IDE, set an environment variable called `SDK_ROOT` to the corresponding path on your machine.

```shell
export SDK_ROOT=[PATH TO RIOTEE SDK]
```
If the arm-none-eabi-gcc toolchain is not on your path, point to it with another environment variable:

```shell
export GNU_INSTALL_ROOT=[PATH TO TOOLCHAIN]
```
As an alternative to these environment variables, you can also set the two variables at the top of the project's [Makefile](./Makefile).

Now build the project and upload it to your Riotee device with
```
make flash
```
### Visual Studio Code

Open the project's folder in Visual Studio Code via `File->Open Folder`.
Adjust the three configuration keys in [.vscode/settings.json](.vscode/settings.json) according to your setup:
 - `sdkRoot`: Path to the Riotee SDK
 - `operSys`: Mac, Linux or Win32
 - `gnuInstallRoot`: Path to arm-none-eabi toolchain

Open `main.c` and check that code-completion works and that all imports are correctly resolved. For example, selecting `riotee_wait_cap_charged()` and pressing `F12` should take you straight into the SDK's code.

To install keyboard shortcuts, press `Ctrl`+`Shift`+`p`, type `Open Keyboard Shortcuts` and press `Enter`, insert the following keybindings and save the file:

```
    {
        "key": "ctrl+alt+b",
        "command": "workbench.action.tasks.runTask",
        "args": "build"
    },
    {
        "key": "ctrl+alt+c",
        "command": "workbench.action.tasks.runTask",
        "args": "clean"
    },
    {
        "key": "ctrl+alt+u",
        "command": "workbench.action.tasks.runTask",
        "args": "flash"
    },
```

Now you can conveniently build, clean and flash the code using the corresponding keyboard shortcuts.