#!/bin/env bash
odin build whine.odin -file -debug
valgrind --show-leak-kinds=all --leak-check=full ./whine.bin
