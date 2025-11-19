# Multiscale PDE Homogenization Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FreeFEM++](https://img.shields.io/badge/FreeFEM%2B%2B-v4.13-blue.svg)](https://freefem.org/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com)

A numerical framework for computing effective coefficients of multiscale partial differential equations (PDEs) using energy minimization methods. Built with FreeFEM++.

---

## 🎯 Overview

This project implements **numerical homogenization** algorithms to compute effective (homogenized) coefficients for elliptic PDEs with rapidly oscillating coefficients. Such problems arise naturally in:

- **Materials Science**: Composite materials, fiber-reinforced structures
- **Porous Media**: Flow in heterogeneous porous media
- **Heat Transfer**: Thermal diffusion in heterogeneous media
- **Structural Mechanics**: Periodic lattice structures

### Mathematical Problem

We solve the multiscale elliptic PDE:

```
-div(A^ε(x) ∇u^ε(x)) = f(x)  in Ω
```

where `A^ε(x)` is a rapidly oscillating (period `ε << 1`) diffusion tensor. Direct numerical simulation is prohibitively expensive due to the need for very fine meshes (`h << ε`).

**Our approach**: Compute the effective tensor `A^eff` such that the homogenized solution `ū` approximates `u^ε` at the macroscopic scale:

```
-div(A^eff ∇ū(x)) = f(x)  in Ω
```

---

## ✨ Features

- **Energy Minimization Algorithm**: Gradient descent with optional Armijo line search
- **Multiple Loading Functions**: Robust computation using 3+ independent loadings
- **Periodic Microstructures**: Built-in support for periodic coefficients
- **Fully Documented Code**: Professional English documentation throughout
- **Modular Architecture**: Clean separation of solvers, algorithms, and I/O
- **Efficient Implementation**: FreeFEM++ sparse solvers with optimized assembly

---

## 📋 Requirements

- **FreeFEM++** ≥ v4.13 ([download here](https://freefem.org/))
- Standard C++ compiler (for FreeFEM++ backend)
- **Optional**: LaTeX (for compiling theory documentation)

### Supported Platforms

- Linux (Ubuntu 20.04+, Debian, Fedora)
- macOS (10.15+)
- Windows (via WSL)

---

## 🚀 Quick Start

### Installation

1. **Install FreeFEM++** (see [Installation Guide](#installation-guide))

2. **Clone the repository**:
   ```bash
   git clone https://github.com/sruget/effective-pde-approximation.git
   cd claude2
   ```

3. **Create output directories**:
   ```bash
   mkdir -p examples/Solution/caseperiodic/coscosloading
   ```

### Run Your First Example

```bash
cd examples

# Step 1: Generate oscillating solutions (periodic microstructure)
FreeFem++ generate_data_caseperiodic.edp

# Step 2: Compute effective coefficients
FreeFem++ run_infsumenergy.edp
```

**Expected output**:
```
Effective coefficient tensor:
  A11 = 19.3378
  A12 = -0.00887136
  A22 = 11.8312
```

**Computation time**: ~8 seconds on a standard laptop

---

## 📂 Project Structure

```
claude2/
├── README.md              # This file
├── LICENSE               # MIT License
├── install.sh            # FreeFEM++ installation script
├── docs/                 # Documentation
│   ├── theory.pdf       # Mathematical theory (compiled LaTeX)
│   └── main.tex         # LaTeX source
├── src/                  # Source code
│   ├── algorithms/      # Optimization algorithms
│   │   └── infsumenergy.edp
│   ├── mesh.edp         # Mesh generation
│   ├── solver.edp       # PDE solvers
│   ├── loading.edp      # Loading functions
│   ├── io.edp           # I/O utilities
│   └── parameters.edp   # Global parameters
└── examples/             # Runnable examples
    ├── README.md        # Examples documentation
    ├── generate_data_caseperiodic.edp
    └── run_infsumenergy.edp
```

---

## 📖 Documentation

### Code Documentation

All source files are fully documented in English with:
- **Function signatures** with parameter descriptions
- **Mathematical formulations** where applicable
- **Usage examples** for key functions
- **Implementation notes** and algorithmic details

### Theory Documentation

- **[docs/theory.pdf](docs/theory.pdf)**: Complete mathematical analysis including:
  - Homogenization theory background
  - Energy minimization formulation
  - Gradient computation and descent algorithm
  - Numerical results and validation

### Examples Guide

See **[examples/README.md](examples/README.md)** for:
- Step-by-step tutorial for each example
- Expected results and computation times
- Troubleshooting common issues
- How to create custom microstructures

---

## 🔬 Algorithm: `infSumEnergy`

The core algorithm computes effective coefficients by minimizing the energy gap:

```
J(A) = Σ_p (E_osc^p - E_macro^p(A))²
```

**Method**: Gradient descent with analytical gradient computation
- **Gradient formula**: Derived from energy functional
- **Line search**: Optional Armijo backtracking for adaptive step size
- **Convergence**: Typically 100-400 iterations

**Key parameters** (in `src/parameters.edp`):
- `Niter = 400`: Maximum iterations
- `rho = 0.1`: Fixed step size (if line search disabled)
- `nbSecondMember = 3`: Number of loading functions

---

## 🎓 Examples

### 1. Periodic Microstructure

**Coefficient**:
```
A11^ε(x,y) = 22 + 10(sin(2πx/ε) + sin(2πy/ε))
A22^ε(x,y) = 12 + 2(sin(2πx/ε) + sin(2πy/ε))
```

**Results**:
- Effective tensor: `A11 ≈ 19.3`, `A22 ≈ 11.8`, `A12 ≈ 0`

See [examples/README.md](examples/README.md) for more examples.

---

## 🛠️ Installation Guide

### Ubuntu/Debian

```bash
# Run the automated install script
bash install.sh

# Or install manually
sudo apt-get update
sudo apt-get install freefem++
```

### macOS

```bash
# Using Homebrew
brew install freefem

# Or download from https://freefem.org/
```

### Verify Installation

```bash
FreeFem++ --version
# Should display: FreeFem++ v4.13 or later
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **FreeFEM++** team for the excellent finite element framework
- This project was developed with assistance from **Claude (Anthropic)** for code documentation, structure optimization, and testing
- Mathematical theory based on classical homogenization results (Bensoussan, Lions, Papanicolaou, 1978)

---

## 📚 Citation

If you use this code in your research, please cite:

```bibtex
@software{multiscale_homogenization,
  author = {Simon Ruget},
  title = {Multiscale PDE Homogenization Framework},
  year = {2024},
  url = {https://github.com/sruget/effective-pde-approximation}
}
```

---

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.
