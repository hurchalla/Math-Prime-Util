# Copyright 2022 Jeffrey Hurchalla
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


if(TARGET compare_factoring)
    return()
endif()

cmake_minimum_required(VERSION 3.14)

project(compare_factoring VERSION 1.0.0 LANGUAGES C CXX)


enable_testing()


if(NOT DEFINED CMAKE_ARCHIVE_OUTPUT_DIRECTORY)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()
if(NOT DEFINED CMAKE_LIBRARY_OUTPUT_DIRECTORY)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()
if(NOT DEFINED CMAKE_RUNTIME_OUTPUT_DIRECTORY)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()


add_executable(compare_factoring)

target_sources(compare_factoring PRIVATE
               test.cpp
               factor.c
               util.c
               primality.c
               cache.c
               sieve.c
               chacha.c
               csprng.c
               prime_powers.c
               prime_counts.c
               prime_count_cache.c
               lmo.c
               legendre_phi.c
               real.c
               inverse_interpolate.c
               )

target_include_directories(compare_factoring PRIVATE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)



target_compile_features(compare_factoring PRIVATE cxx_std_17)


include(FetchContent)

FetchContent_Declare(
    hurchalla_util
    GIT_REPOSITORY https://github.com/hurchalla/util.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(hurchalla_util)
target_link_libraries(compare_factoring
                      PRIVATE hurchalla_util)

FetchContent_Declare(
    modular_arithmetic
    GIT_REPOSITORY https://github.com/hurchalla/modular_arithmetic.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(modular_arithmetic)
target_link_libraries(compare_factoring
                      PRIVATE hurchalla_modular_arithmetic)

FetchContent_Declare(
    factoring
    GIT_REPOSITORY https://github.com/hurchalla/factoring.git
    GIT_TAG        master
)
FetchContent_MakeAvailable(factoring)
target_link_libraries(compare_factoring
                      PRIVATE hurchalla_factoring)

