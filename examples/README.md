# Examples Guide

This directory contains runnable examples demonstrating the multiscale PDE homogenization framework. Each example is self-contained and documented with expected results.

---

## 📋 Table of Contents

1. [Periodic Microstructure](#1-periodic-microstructure)
2. [Random Checkerboard (Advanced)](#2-random-checkerboard-advanced)
3. [Troubleshooting](#troubleshooting)
4. [Creating Custom Examples](#creating-custom-examples)

---

## Prerequisites

Before running any example, ensure that:

1. **FreeFEM++ is installed** and accessible via command line:
   ```bash
   FreeFem++ --version
   ```

2. **Output directories exist**:
   ```bash
   mkdir -p Solution/caseperiodic/coscosloading
   mkdir -p Solution/caserandom/coscosloading  # For random checkerboard
   ```

3. **You are in the examples directory**:
   ```bash
   cd examples/
   ```

---

## 1. Periodic Microstructure

### Description

This example computes the effective diffusion tensor for a **periodic heterogeneous medium** with sinusoidal coefficient variations.

**Physical interpretation**: Represents a material with periodic microstructure (e.g., fiber-reinforced composite with regular spacing).

### Oscillating Coefficient

The diffusion tensor oscillates periodically with period `ε = 0.1`:

```
A11^ε(x,y) = 22 + 10(sin(2πx/ε) + sin(2πy/ε))  ∈ [2, 42]
A12^ε(x,y) = 0
A22^ε(x,y) = 12 + 2(sin(2πx/ε) + sin(2πy/ε))   ∈ [8, 16]
```

### Step-by-Step Execution

#### Step 1: Generate Oscillating Solutions

```bash
FreeFem++ generate_data_caseperiodic.edp
```

**What this does**:
- Generates a coarse mesh (20×20 elements)
- Defines the periodic coefficient `A^ε(x,y)`
- Solves the oscillating PDE for 3 different loadings
- Saves solutions to `./Solution/caseperiodic/coscosloading/`

**Expected output**:
```
Solving oscillating PDE for 3 loadings...
  Loading 1/3... saved to ./Solution/caseperiodic/coscosloading/SolutionOscillating_p0_eps0.1_h0.0037037.txt
  Loading 2/3... saved to ./Solution/caseperiodic/coscosloading/SolutionOscillating_p1_eps0.1_h0.0037037.txt
  Loading 3/3... saved to ./Solution/caseperiodic/coscosloading/SolutionOscillating_p2_eps0.1_h0.0037037.txt
Data generation complete!
```

**Computation time**: ~0.02 seconds

#### Step 2: Compute Effective Coefficients

```bash
FreeFem++ run_infsumenergy.edp
```

**What this does**:
- Loads the 3 pre-computed oscillating solutions
- Computes oscillating energies
- Runs the `infSumEnergy` optimization algorithm (400 iterations)
- Displays the effective tensor

**Expected output**:
```
Loading oscillating solutions...
  Loading solution 1: ./Solution/caseperiodic/coscosloading/SolutionOscillating_p0_eps0.1_h0.0037037.txt
  Loading solution 2: ./Solution/caseperiodic/coscosloading/SolutionOscillating_p1_eps0.1_h0.0037037.txt
  Loading solution 3: ./Solution/caseperiodic/coscosloading/SolutionOscillating_p2_eps0.1_h0.0037037.txt

Computing oscillating energies...
  E_osc[0] = 5.63185e-05
  E_osc[1] = 5.07312e-05
  E_osc[2] = 4.89079e-05

============================================
Starting optimization algorithm
============================================
Initial guess: A11 = 16, A12 = 0, A22 = 4
Number of iterations: 400
Step size: 0.1 (fixed step)
Number of loadings: 3
============================================

============================================
OPTIMIZATION COMPLETE
============================================
Effective coefficient tensor:
  A11 = 19.33
  A12 = -0.00887136
  A22 = 11.8
============================================
```

**Computation time**: ~7-8 seconds

---

## 2. Random Checkerboard (Advanced)

### Description

This example handles **stochastic homogenization** for a random checkerboard pattern.

**Status**: File `generate_data_caserandomcheckerboard.edp` exists but requires:
- Monte Carlo sampling (40 realizations)
- Statistical post-processing
- Longer computation time

**To run** (if implemented):
```bash
FreeFem++ generate_data_caserandomcheckerboard.edp
# Note: This will take significantly longer (~few minutes)
```

---

## Troubleshooting

### Common Issues

#### 1. **Error: Cannot open file `./Solution/...`**

**Solution**: Create the output directory:
```bash
mkdir -p Solution/caseperiodic/coscosloading
```

#### 2. **Error: `FreeFem++: command not found`**

**Solution**: Install FreeFEM++ or add it to your PATH:
```bash
# Ubuntu/Debian
sudo apt-get install freefem++

# macOS
brew install freefem
```

#### 3. **Warning: `UMFPACK WARNING singular matrix`**

**Cause**: Occurs during optimization when the effective tensor becomes ill-conditioned.

**Impact**: Usually benign if it occurs only occasionally. If persistent, check:
- Initial guess `Ainit` in `src/parameters.edp`
- Step size `rho` (try smaller value like 0.01)

#### 4. **Results differ from expected values**

**Possible causes**:
- Different FreeFEM++ version (try v4.13)
- Different mesh resolution (check `H` parameter)
- Incomplete convergence (increase `Niter`)

**Debug**:
```bash
# Increase iterations for better convergence
# Edit src/parameters.edp:
int Niter = 1000;  # Instead of 400
```

#### 5. **Computation is very slow**

**Causes**:
- Fine mesh (`H` too small)
- Too many iterations (`Niter` too large)
- Line search enabled (slower but more robust)

**Quick fix**: Use fixed step size by setting `linesearch = 0` in `run_infsumenergy.edp`:
```cpp
real[int] Aeff = infSumEnergy(Ainit, energyOscillating, loadings,
                            0,  // <-- Set to 0 for fixed step
                            nbSecondMember, Niter, rho, m1, Th);
```

---

## Creating Custom Examples

### Template for New Microstructures

To create your own example (e.g., `generate_data_mycase.edp`):

```cpp
include "../src/parameters.edp"
include "../src/mesh.edp"
include "../src/loading.edp"
include "../src/solver.edp"
include "../src/io.edp"

// Build Mesh
mesh Th = buildMesh(Lx, Ly, floor(1./H));
fespace Vh(Th, P1);
Vh ueps;

// Define YOUR oscillating coefficient
func Aeps11func = /* your formula */;
func Aeps12func = /* your formula */;
func Aeps22func = /* your formula */;

Vh A11 = Aeps11func(x,y);
Vh A12 = Aeps12func(x,y);
Vh A22 = Aeps22func(x,y);

// Assemble stiffness matrix
matrix A = stiffnessMatrix(Th, A11[], A12[], A22[]);
set(A,solver=sparsesolver);

// Generate loadings
real[int, int] loadings = coscosLoading(Th, nbSecondMember);

// Solve and save
for (int p = 0; p<nbSecondMember; p++){
    real[int] Bp = linearForm(Th, loadings(p,:));
    real[int] sol = A^-1*Bp;
    ueps[] = sol(0:sol.n-1);

    string filename = "./Solution/mycase/SolutionOscillating_p"+p+".txt";
    saveSolution(ueps[], filename);
}
```

### Example Coefficient Ideas

1. **Layered material** (1D periodicity):
   ```cpp
   func Aeps11func = (sin(2*pi*x/eps) > 0) ? 20.0 : 5.0;
   ```

2. **Circular inclusions**:
   ```cpp
   func radius = 0.3*eps;
   func Aeps11func = (x^2 + y^2 < radius^2) ? 50.0 : 10.0;
   ```

3. **Smooth random field** (requires external data):
   ```cpp
   // Load from file with random field values
   ```

---

## Performance Tips

- **Use coarse mesh**: `H = 0.05` is a good balance between accuracy and speed
- **Start with few iterations**: Try `Niter = 50` first to check everything works
- **Use fixed step size**: Faster than line search for well-conditioned problems
- **Reduce loadings**: `nbSecondMember = 1` for quick tests (but less robust)

---

## Further Reading

- **Main README**: `../README.md` - General project overview
- **Theory PDF**: `../docs/theory.pdf` - Mathematical background
- **Source code**: `../src/` - All modules are fully documented

---

## Need Help?

If you encounter issues not covered here:
1. Check the main [README.md](../README.md)
2. Open an issue on GitHub
3. Verify FreeFEM++ version compatibility

Happy computing! 🚀
