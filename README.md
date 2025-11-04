# Effective Approximation for Multiscale PDEs

This repository provides a framework for building **effective approximations of multiscale partial differential equations (PDEs)**. It contains implementations of numerical algorithms to compute effective coefficients and solve PDEs efficiently on complex heterogeneous domains.

---

## 📂 Repository Structure
.  
├── src/  
│ ├── algorithms/ # Core numerical methods for effective coefficient computation  
│ │ ├── infsumenergy.edp
│ │ ├── infsumenergyperturbation.edp
│ ├── io.edp # Input/output routines
│ ├── loading.edp # Right-hand sides and boundary conditions
│ ├── mesh.edp # Mesh generation
│ ├── parameters.edp # Parameter configuration
│ ├── solver_homdir.edp # Homogeneous Dirichlet problem solver
│ ├── solver_neumann.edp # Neumann boundary condition solver
│ 
├── examples/
├── generate_data_caseperiodic.edp # Case of a periodic microstructure
├── generate_data_caserandomcheckerboard.edp # Case of a random checkerboard
├── run_infsumenergy.edp # Compute effective coefficient using strategy infsupenergy


---

## Overview

Multiscale PDEs arise in numerous physical and engineering applications (e.g., porous media flow, composite materials, or heat transfer in heterogeneous media). Direct numerical simulation of such problems is computationally expensive due to fine-scale variations.

This project implements **effective approximation methods**, allowing for:
- Construction of **homogenized (effective) coefficients**,
- Solution of **macroscopic problems** with reduced computational cost,
- Benchmarking of different **multiscale algorithms**.

The implementation leverages the **FreeFEM++** framework for flexible finite element discretization and efficient PDE solving.

---

## Dependencies

- [FreeFEM++](https://freefem.org/) (≥ v4.5 recommended)
- Standard C++ compiler (for FreeFEM back-end)

To verify FreeFEM++ installation:
```bash
FreeFem++ --version
