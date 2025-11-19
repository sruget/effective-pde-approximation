#!/bin/bash
# ============================================================================
# FreeFEM++ Installation Script
# ============================================================================
# This script automates the installation of FreeFEM++ on Linux systems.
# Supports Ubuntu, Debian, Fedora, and macOS (via Homebrew).
#
# Usage:
#   bash install.sh
#
# Or with sudo privileges:
#   sudo bash install.sh
# ============================================================================

set -e  # Exit on error

echo "============================================"
echo "FreeFEM++ Installation Script"
echo "============================================"
echo ""

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        echo "Error: Cannot detect Linux distribution"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    OS="macos"
else
    echo "Error: Unsupported operating system: $OSTYPE"
    echo "Please install FreeFEM++ manually from https://freefem.org/"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Installation based on OS
case $OS in
    ubuntu|debian)
        echo "Installing FreeFEM++ on Ubuntu/Debian..."
        echo ""

        # Check if running as root
        if [ "$EUID" -ne 0 ]; then
            echo "This script requires sudo privileges."
            echo "Please run: sudo bash install.sh"
            exit 1
        fi

        echo "Step 1/3: Updating package lists..."
        apt-get update -qq

        echo "Step 2/3: Installing dependencies..."
        apt-get install -y -qq \
            build-essential \
            gfortran \
            libblas-dev \
            liblapack-dev \
            libhdf5-dev \
            libopenmpi-dev

        echo "Step 3/3: Installing FreeFEM++..."
        apt-get install -y freefem++

        ;;

    fedora|rhel|centos)
        echo "Installing FreeFEM++ on Fedora/RHEL/CentOS..."
        echo ""

        if [ "$EUID" -ne 0 ]; then
            echo "This script requires sudo privileges."
            echo "Please run: sudo bash install.sh"
            exit 1
        fi

        echo "Step 1/2: Installing dependencies..."
        dnf install -y gcc-gfortran openmpi-devel blas-devel lapack-devel hdf5-devel

        echo "Step 2/2: Installing FreeFEM++..."
        dnf install -y freefem++

        ;;

    macos)
        echo "Installing FreeFEM++ on macOS..."
        echo ""

        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo "Error: Homebrew is not installed."
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi

        echo "Updating Homebrew..."
        brew update

        echo "Installing FreeFEM++..."
        brew install freefem

        ;;

    *)
        echo "Error: Unsupported Linux distribution: $OS"
        echo ""
        echo "Please install FreeFEM++ manually:"
        echo "  1. Visit https://freefem.org/"
        echo "  2. Download the appropriate package for your system"
        echo "  3. Follow the installation instructions"
        exit 1
        ;;
esac

echo ""
echo "============================================"
echo "Installation complete!"
echo "============================================"
echo ""

# Verify installation
echo "Verifying installation..."
if command -v FreeFem++ &> /dev/null; then
    VERSION=$(FreeFem++ --version 2>&1 | head -1 || echo "Unknown version")
    echo "✓ FreeFEM++ is installed: $VERSION"
    echo ""
    echo "You can now run the examples:"
    echo "  cd examples/"
    echo "  FreeFem++ generate_data_caseperiodic.edp"
    echo "  FreeFem++ run_infsumenergy.edp"
else
    echo "✗ Warning: FreeFem++ command not found in PATH"
    echo ""
    echo "You may need to:"
    echo "  1. Restart your terminal"
    echo "  2. Add FreeFEM++ to your PATH"
    echo "  3. Check the installation logs above for errors"
fi

echo ""
echo "============================================"
echo "Next Steps"
echo "============================================"
echo "1. Create output directories:"
echo "   mkdir -p examples/Solution/caseperiodic/coscosloading"
echo ""
echo "2. Run the periodic microstructure example:"
echo "   cd examples"
echo "   FreeFem++ generate_data_caseperiodic.edp"
echo "   FreeFem++ run_infsumenergy.edp"
echo ""
echo "3. Read the documentation:"
echo "   - Main README: README.md"
echo "   - Examples guide: examples/README.md"
echo "   - Theory: docs/theory.pdf"
echo ""
echo "For help, see: https://github.com/sruget/effective-pde-approximation"
echo "============================================"
