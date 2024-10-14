#!/bin/bash

# Inform the user what this script is for
echo "This script will install AzerothCore and its dependencies, including MySQL server and additional modules."
read -p "Do you want to continue with the installation process? (y/n): " choice

# Check if the user wants to proceed
if [[ "$choice" != "y" ]]; then
    echo "Installation canceled."
    exit 1
fi

# Adding a wait time for user to read
sleep 2

# Update package list and install dependencies
sudo apt-get update && sudo apt-get install -y git cmake make gcc g++ clang libmysqlclient-dev \
    libssl-dev libbz2-dev libreadline-dev libncurses-dev mysql-server libboost-all-dev

# Adding a wait time for user to read
echo "Dependencies installed."
sleep 3

# Cloning AzerothCore repository
echo "Cloning AzerothCore repository..."
git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch $HOME/azerothcore-source
sleep 3

# Cloning Mod Eluna Lua repository
echo "Cloning Mod Eluna Lua module..."
git clone https://github.com/azerothcore/mod-eluna.git $HOME/azerothcore-source/modules/mod-eluna
sleep 3

# Create build directory inside azerothcore-source
echo "Creating build directory inside azerothcore-source..."
mkdir $HOME/azerothcore-source/build
cd $HOME/azerothcore-source/build
sleep 3

# Configure the build with CMake
echo "Configuring the build..."
cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/azerothcore-source/env/dist/ \
    -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DWITH_WARNINGS=1 -DTOOLS_BUILD=all -DSCRIPTS=static -DMODULES=static
sleep 3

# Build with all available cores
cores=$(nproc --all)
echo "Building AzerothCore with $cores cores..."
sleep 2
make -j $cores

# Install after build is successful
if [[ $? -eq 0 ]]; then
    echo "Build completed successfully. Installing..."
    sleep 2
    make install
    echo "Installation complete!"
else
    echo "Build failed. Exiting..."
    exit 1
fi
