# API Documentation

Complete reference for all functions in the Multiscale PDE Homogenization Framework.

---

## Table of Contents

- [Mesh Generation](#mesh-generation)
- [Solvers](#solvers)
- [Loading Functions](#loading-functions)
- [I/O Utilities](#io-utilities)
- [Algorithms](#algorithms)
- [Parameters](#parameters)

---

## Mesh Generation

### `buildMesh()`

**File**: `src/mesh.edp`

Generates a structured triangular mesh for a rectangular domain.

**Signature**:
```cpp
func mesh buildMesh(real Lx, real Ly, int n)
```

**Parameters**:
- `Lx` (real): Domain length in x-direction
- `Ly` (real): Domain length in y-direction
- `n` (int): Number of mesh points per boundary segment

**Returns**:
- `mesh`: Triangular mesh covering [0,Lx]×[0,Ly]

**Boundary Labels**:
- Label 1: Bottom boundary (y = 0)
- Label 2: Right boundary (x = Lx)
- Label 3: Top boundary (y = Ly)
- Label 4: Left boundary (x = 0)

**Example**:
```cpp
mesh Th = buildMesh(1.0, 1.0, 20);  // Unit square, 20 points per side
```

---

## Solvers

### `stiffnessMatrix()`

**File**: `src/solver.edp`

Assembles the stiffness matrix for the diffusion operator `-div(A∇u)` with homogeneous Dirichlet boundary conditions.

**Signature**:
```cpp
func matrix stiffnessMatrix(mesh &Th, real[int] A11, real[int] A12, real[int] A22)
```

**Parameters**:
- `Th` (mesh&): Computational mesh
- `A11` (real[int]): Diffusion tensor component A₁₁
- `A12` (real[int]): Diffusion tensor component A₁₂
- `A22` (real[int]): Diffusion tensor component A₂₂

**Returns**:
- `matrix`: Assembled stiffness matrix with Dirichlet BC

**Notes**:
- Uses `optimize=0` flag to prevent numerical issues
- Boundary conditions applied on labels 1-4

**Example**:
```cpp
Vh A11 = 22.0;  // Constant coefficient
Vh A12 = 0.0;
Vh A22 = 12.0;
matrix A = stiffnessMatrix(Th, A11[], A12[], A22[]);
set(A, solver=sparsesolver);
```

---

### `linearForm()`

**File**: `src/solver.edp`

Assembles the right-hand side vector for a loading applied in the domain.

**Signature**:
```cpp
func real[int] linearForm(mesh &Th, real[int] field)
```

**Parameters**:
- `Th` (mesh&): Computational mesh
- `field` (real[int]): Loading field values (size = ndof)

**Returns**:
- `real[int]`: Right-hand side vector

**Mathematical Formulation**:
```
b = ∫_Ω f(x) v(x) dx
```

**Example**:
```cpp
real[int, int] loadings = coscosLoading(Th, 3);
real[int] b = linearForm(Th, loadings(0,:));  // First loading
```

---

## Loading Functions

### `coscosLoading()`

**File**: `src/loading.edp`

Generates orthonormal cosine-based loading functions with Gram-Schmidt orthogonalization.

**Signature**:
```cpp
func real[int, int] coscosLoading(mesh &Th, int nbSecondMember)
```

**Parameters**:
- `Th` (mesh&): Computational mesh
- `nbSecondMember` (int): Number of loading functions to generate

**Returns**:
- `real[int, int]`: Matrix (nbSecondMember × ndof) of loading vectors

**Mathematical Formulation**:
```
f_p(x,y) = cos(nx_p π x) cos(ny_p π y)
```

Orthogonalized with respect to boundary L2 inner product:
```
⟨f,g⟩ = ∫_∂Ω f g ds
```

**Example**:
```cpp
real[int, int] loadings = coscosLoading(Th, 3);  // 3 orthonormal loadings
```

**Notes**:
- Frequency pairs (nx, ny) chosen to avoid redundancy
- Typically use 3-10 loadings for robust computation

---

### `sinsinLoading()`

**File**: `src/loading.edp`

Generates normalized sine-based loading functions (L2 normalization in domain).

**Signature**:
```cpp
func real[int, int] sinsinLoading(mesh &Th, int nbSecondMember)
```

**Parameters**:
- `Th` (mesh&): Computational mesh
- `nbSecondMember` (int): Number of loading functions

**Returns**:
- `real[int, int]`: Matrix (nbSecondMember × ndof) of loading vectors

**Mathematical Formulation**:
```
f_p(x,y) = sin(nx_p π x) sin(ny_p π y)
```

Normalized to unit L2 norm:
```
||f_p||_L2(Ω) = 1
```

**Example**:
```cpp
real[int, int] loadings = sinsinLoading(Th, 5);
```

**Notes**:
- Loadings satisfy homogeneous Dirichlet BC naturally (f = 0 on ∂Ω)
- NOT orthogonalized (unlike coscosLoading)

---

## I/O Utilities

### `saveSolution()`

**File**: `src/io.edp`

Saves a solution vector to a text file.

**Signature**:
```cpp
func int saveSolution(real[int] u, string filename)
```

**Parameters**:
- `u` (real[int]): Solution vector to save
- `filename` (string): Output file path

**Returns**:
- `int`: 0 on success

**File Format**:
```
Line 1: Array size (integer)
Following lines: Array values (5 per line by default)
```

**Example**:
```cpp
Vh u;  // Some FE function
saveSolution(u[], "./output/solution.txt");
```

---

### `loadSolution()`

**File**: `src/io.edp`

Loads a solution vector from a text file.

**Signature**:
```cpp
func int loadSolution(real[int] &u, string filename)
```

**Parameters**:
- `u` (real[int]&): Reference to solution vector (must be pre-allocated)
- `filename` (string): Input file path

**Returns**:
- `int`: 0 on success

**Example**:
```cpp
fespace Vh(Th, P1);
Vh u;
real[int] uval(u[].n);  // Pre-allocate
loadSolution(uval, "./input/solution.txt");
u[] = uval;
```

**Important**:
- Vector `u` must be pre-allocated with correct size
- File must match format from `saveSolution()`

---

## Algorithms

### `infSumEnergy()`

**File**: `src/algorithms/infsumenergy.edp`

Computes effective coefficients via energy minimization using gradient descent.

**Signature**:
```cpp
func real[int] infSumEnergy(
    real[int] Ainit,
    real[int] energyOscillating,
    real[int, int] loadings,
    int linesearch,
    real nbSecondMember,
    real Niter,
    real rho,
    real m1,
    mesh &TH
)
```

**Parameters**:
- `Ainit` (real[int]): Initial guess [A11, A12, A22]
- `energyOscillating` (real[int]): Energies of oscillating solutions
- `loadings` (real[int,int]): Loading vectors matrix
- `linesearch` (int): 0 = fixed step, 1 = Armijo line search
- `nbSecondMember` (real): Number of loadings
- `Niter` (real): Maximum iterations
- `rho` (real): Fixed step size (if linesearch=0)
- `m1` (real): Armijo parameter (if linesearch=1)
- `TH` (mesh&): Computational mesh

**Returns**:
- `real[int]`: Optimized effective tensor [A11, A12, A22]

**Mathematical Formulation**:

Minimizes the cost function:
```
J(A) = Σ_p (E_osc^p - E_macro^p(A))²
```

**Gradient**:
```
∂J/∂A11 = Σ_p 2(E_osc^p - E_macro^p) ∫_Ω (∂ū_p/∂x)² dx
∂J/∂A12 = Σ_p 4(E_osc^p - E_macro^p) ∫_Ω (∂ū_p/∂x)(∂ū_p/∂y) dx
∂J/∂A22 = Σ_p 2(E_osc^p - E_macro^p) ∫_Ω (∂ū_p/∂y)² dx
```

**Example**:
```cpp
real[int] Ainit = [16., 0., 4.];
real[int] Aeff = infSumEnergy(
    Ainit, energyOsc, loadings,
    0,    // Fixed step
    3,    // 3 loadings
    400,  // 400 iterations
    0.1,  // Step size
    0.1,  // Armijo param (unused)
    Th
);
```

**Convergence Tips**:
- Start with good initial guess (close to expected values)
- Use 100-400 iterations
- Fixed step (linesearch=0) is faster but may diverge
- Armijo (linesearch=1) is more robust

---

### `lineSearchArmijo()`

**File**: `src/algorithms/infsumenergy.edp`

Performs backtracking line search with Armijo condition (internal function).

**Signature**:
```cpp
func real[int] lineSearchArmijo(
    real[int, int] loadings,
    int nbSecondMember,
    real[int] AbarL,
    real[int] dir,
    real costfunc,
    real[int] energyOscillating,
    real bound,
    mesh &TH,
    real rescalefactor
)
```

**Returns**:
- `real[int]`: Updated coefficient satisfying Armijo condition

**Armijo Condition**:
```
J(A - ρ∇J) ≤ J(A) + m₁ρ⟨∇J, -∇J⟩
```

**Notes**:
- Called internally by `infSumEnergy()`
- Maximum 7 backtracking iterations
- Step size reduced by factor 2 each iteration

---

## Parameters

**File**: `src/parameters.edp`

### Mesh Parameters

| Parameter | Type   | Default | Description |
|-----------|--------|---------|-------------|
| `eps`     | real   | 0.1     | Microscale parameter (ε) |
| `r`       | real   | 27.0    | Resolution ratio (ε/h) |
| `h`       | real   | eps/r   | Fine mesh parameter |
| `H`       | real   | 0.05    | Coarse mesh parameter |
| `Lx`      | real   | 1.0     | Domain length (x) |
| `Ly`      | real   | 1.0     | Domain length (y) |

### Data Parameters

| Parameter        | Type | Default | Description |
|------------------|------|---------|-------------|
| `nbSecondMember` | int  | 3       | Number of loadings |
| `nbMonteCarlo`   | int  | 40      | Monte Carlo samples |
| `nbMonteCarlo2`  | int  | 40      | Samples for CI |

### Optimization Parameters

| Parameter | Type      | Default         | Description |
|-----------|-----------|-----------------|-------------|
| `Niter`   | int       | 400             | Max iterations |
| `rho`     | real      | 0.1             | Step size |
| `Ainit`   | real[int] | [16., 0., 4.]   | Initial guess |
| `m1`      | real      | 0.1             | Armijo param |

---

## Usage Examples

### Complete Workflow

```cpp
// 1. Setup
include "../src/parameters.edp"
include "../src/mesh.edp"
include "../src/loading.edp"
include "../src/solver.edp"
include "../src/io.edp"
include "../src/algorithms/infsumenergy.edp"

// 2. Generate mesh
mesh Th = buildMesh(Lx, Ly, floor(1./H));
fespace Vh(Th, P1);

// 3. Define coefficient
func Aeps11 = 22 + 10*sin(2*pi*x/eps);
func Aeps22 = 12 + 2*sin(2*pi*x/eps);
Vh A11 = Aeps11(x,y);
Vh A22 = Aeps22(x,y);

// 4. Solve oscillating problem
matrix A = stiffnessMatrix(Th, A11[], 0*A11[], A22[]);
set(A, solver=sparsesolver);

real[int, int] loadings = coscosLoading(Th, 3);
// ... solve and save solutions ...

// 5. Compute effective coefficients
real[int] energyOsc = [...];  // Compute energies
real[int] Aeff = infSumEnergy(Ainit, energyOsc, loadings,
                            0, 3, 400, 0.1, 0.1, Th);

cout << "A11 = " << Aeff[0] << endl;
cout << "A12 = " << Aeff[1] << endl;
cout << "A22 = " << Aeff[2] << endl;
```

---

## Error Handling

Most functions return integers (0 on success) or arrays. Common errors:

- **File I/O**: Check file paths and permissions
- **Mesh**: Ensure `n > 0` in `buildMesh()`
- **Array sizes**: Pre-allocate arrays with correct dimensions
- **Convergence**: Increase `Niter` or adjust `rho` if optimization fails

---

## See Also

- [Main README](../README.md)
- [Examples Guide](../examples/README.md)
- [Theory Documentation](theory.pdf)
