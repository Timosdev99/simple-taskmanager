# Task Manager CLI

this is a simple `command line interface` is a simple tool that help to efficiently manage tasks using the terminal.

it allow user to add, list and update status of the task. the task are then stored in a .txt file

## How to use 

1. **clone repository**

```sh
git clone https://github.com/Timosdev99/simple-taskmanager.git
cd simple-taskmanager
```

2. **run the application**

```sh
zig run src/taskmanager.zig
```

3. **build the application**

```sh 
zig build-exe src/taskmanager.zig
```

## command

1. **to add task**

```sh
./taskmanager add "Task"
```

2. **check task list**

```sh
./taskmanager list
```

3. **to update status (complete or incomplete)**

```sh
./taskmanager complete "TaskNUmber"
```

## Contributio

feel free to fork this repository, make your changes, and submit a pull request. For major changes, please open an issue first to discuss what you would like to change.