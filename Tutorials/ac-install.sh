#!/bin/bash

# Inform the user what this script is for
echo
echo "This script will install AzerothCore and its dependencies, configure MySQL server, and create the required MySQL user."
echo
read -p "Do you want to continue with the installation process? (y/n): " choice

# Check if the user wants to proceed
if [[ "$choice" != "y" ]]; then
    echo "Installation canceled."
    exit 1
fi

# Adding a wait time for user to read
sleep 5

# Update package list and install dependencies
sudo apt-get update && sudo apt-get install -y git cmake make gcc g++ clang libmysqlclient-dev \
    libssl-dev libbz2-dev libreadline-dev libncurses-dev mysql-server libboost-all-dev

# Adding a wait time for user to read
echo
echo "Dependencies installed."
sleep 5

# Configure MySQL server
echo
echo "Configuring MySQL server and creating user..."
sleep 3
sudo service mysql start
sleep 3
# MySQL user creation
mysql -u root <<EOF
DROP USER IF EXISTS 'acore'@'localhost';
DROP USER IF EXISTS 'acore'@'%';
CREATE USER 'acore'@'%' IDENTIFIED BY 'acore' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0;
GRANT ALL PRIVILEGES ON *.* TO 'acore'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Adding a wait time for user to read
echo
echo "MySQL user 'acore' created and configured for all hosts."
sleep 5

# Cloning AzerothCore repository
echo
echo "Cloning AzerothCore repository..."
sleep 5
git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch $HOME/azerothcore-source


# Cloning Mod Eluna Lua repository
echo
echo "Cloning Mod Eluna Lua module..."
sleep 5
git clone https://github.com/azerothcore/mod-eluna.git $HOME/azerothcore-source/modules/mod-eluna


# Create build directory inside azerothcore-source
echo
echo "Creating build directory inside azerothcore-source..."
sleep 5
mkdir $HOME/azerothcore-source/build
cd $HOME/azerothcore-source/build


# Configure the build with CMake
echo
echo "Configuring the build..."
sleep 5
cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/azerothcore-source/env/dist/ \
    -DCMAKE_C_COMPILER=/usr/bin/clang -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DWITH_WARNINGS=1 -DTOOLS_BUILD=all -DSCRIPTS=static -DMODULES=static


# Build with all available cores
cores=$(nproc --all)
echo "Building AzerothCore with $cores cores..."
sleep 5
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
