cmake_minimum_required(VERSION 3.28)
project(cpp_reflection CXX)
set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(app main.cpp)
# P2996 reflection is gated behind -freflection-latest on clang-p2996.
target_compile_options(app PRIVATE -freflection-latest -Wall -Wextra)
