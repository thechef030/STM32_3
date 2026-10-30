cmake_minimum_required(VERSION 3.22)

#
# This file is generated only once,
# and is not re-generated if converter is called multiple times.
#
# User is free to modify the file as much as necessary
#

# Setup compiler settings
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)


# Define the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Set the project name
set(CMAKE_PROJECT_NAME ece2_474)

# Enable compile command to ease indexing with e.g. clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# Core project settings
project(${CMAKE_PROJECT_NAME})
message("Build type: " ${CMAKE_BUILD_TYPE})

# Enable CMake support for ASM and C languages
enable_language(C ASM)

# Create an executable object type
add_executable(${CMAKE_PROJECT_NAME})

# Add STM32CubeMX generated sources
add_subdirectory(cmake/stm32cubemx)

# Link directories setup
target_link_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined library search paths
)

# Add sources to executable
target_sources(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user sources here
    Core/Src/ece2_474_stdio.c
    Core/Src/ece2_474_routine.c
)

# Add include paths
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    # Add user defined include paths
)

set(STM32_3_TASK "8" CACHE STRING "8/9/10/11=SPI")
set(STM32_3_RX "0" CACHE STRING "0=master TX, 1=slave RX")
set(SPI_TEST_BYTE "0x55" CACHE STRING "Fixed byte when cycling is disabled")
set(SPI_CYCLE_PATTERNS "1" CACHE STRING "1=55/A5/00/FF, 0=fixed byte")
if(NOT STM32_3_TASK MATCHES "^(8|9|10|11)$")
 message(FATAL_ERROR "STM32_3_TASK must be 8, 9, 10 or 11; Task12 uses FPGA only")
endif()
if(NOT STM32_3_RX MATCHES "^[01]$" OR NOT SPI_CYCLE_PATTERNS MATCHES "^[01]$")
 message(FATAL_ERROR "STM32_3_RX and SPI_CYCLE_PATTERNS must be 0 or 1")
endif()
if((STM32_3_TASK STREQUAL "11" AND NOT STM32_3_RX STREQUAL "1") OR
   (STM32_3_TASK MATCHES "^(8|10)$" AND NOT STM32_3_RX STREQUAL "0"))
 message(FATAL_ERROR "Task8/10 require TX; Task11 requires RX")
endif()

# Add project symbols (macros)
target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE
    STM32_3_TASK=${STM32_3_TASK}
    STM32_3_RX=${STM32_3_RX}
    SPI_TEST_BYTE=${SPI_TEST_BYTE}
    SPI_CYCLE_PATTERNS=${SPI_CYCLE_PATTERNS}
)

# Remove wrong libob.a library dependency when using cpp files
list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_LIBRARIES ob)

# Add linked libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    stm32cubemx

    # Add user defined libraries
)
