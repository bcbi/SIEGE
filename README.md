# SIEGE
🏹 SysImage Exports for General Environments 🏰

## Description

Julia's package manager relies on internet access, so it can be challenging to make package dependencies available on secure systems.
One solution is to use containers, but [PackageCompiler](https://github.com/JuliaLang/PackageCompiler.jl) makes it possible to solve the problem entirely within Julia.
This package takes a Julia project and generates a sysimage for use in secure systems.
It also includes a Bash script that starts an offline Julia session with the new sysimage.
The script sets environment variables and accepts command-line arguments, so it can be aliased to `julia` by users.
The main requirement is an internet-connected build server that has the same architecture as the secure system.

## Requirements

__Julia__: SIEGE looks for Julia in the package's main directory.
The binaries can be [downloaded from the official site](https://julialang.org/downloads/) and uploaded to the secure system.
They are not modified in any way by SIEGE,
so this only needs to be done by the developer once, or whenever a new version of Julia is needed.
The same version of Julia should be used to generate the sysimage.

__Manifest__: Copy the Manifest file from your Julia projet into `env/`.
This machine-generated manifest file is what is actually used by PackageCompiler.jl,
so the build server and secure server must be as similar as possible.
An example Julia project space is already included in `env/`.

Additionally, the instructions and code presuppose a *NIX type environment with Bash, but a port for Windows should be possible.

## Instructions:
1. Read through `src/SIEGE.jl`, making changes as needed. The path to SIEGE should be modified within `run_sysimage.sh`.
1. Run `main()` from `src/SIEGE.jl` on the build server to build the sysimage and depot. Any generated files will be found in `build/`.

```
pkg> activate --temp
pkg> develop Path/To/SIEGE
julia> using SIEGE
julia> main("/Path/To/SIEGE")
```

2. Upload the package directory to the secure system.
5. Users can now use `run_sysimage.sh`. Group and permisson settings might need to be adjusted with `chgroup` and `chmod`, since many files need to be executable by users.
5. (OPTIONAL): Add to `~/.bashrc` an alias pointing to the script. It should accept command line arguments just as the Julia binary would.
```
alias julia='Path/To/run_sysimage.sh'
```

## Troubleshooting
1. Certain packages download dependencies only after they are called (lazy loading).
Try running the sysimage on the build server to see if any additional packages are downloaded at runtime.
If required dependencies are left out, these can be added manually:
    - MKL: https://github.com/JuliaLang/PackageCompiler.jl/issues/639#issuecomment-974681443

2. Some packages might just not be relocatable yet and would need to be patched.

