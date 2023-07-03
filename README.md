# SIEGE
🏹 SysImage Exports for General Environments 🏰

## Description

Julia's package manager relies on internet access, so it can be challenging to make dependencies available on secure systems.
[PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl) compiles Julia code ahead of time, primarily for [improved performance in certain workflows](https://julialang.github.io/PackageCompiler.jl/dev/index.html#PackageCompiler).
In particular, [generating a sysimage](https://julialang.github.io/PackageCompiler.jl/dev/sysimages.html) produces a performant stand-alone Julia session, and since its [main drawback (version locking)](https://julialang.github.io/PackageCompiler.jl/dev/sysimages.html#Drawbacks-to-custom-sysimages) is mitigated on secure systems, it is a good approach for putting a Julia session on a system without internet or `ssh` access available to users.
The main requirement is an internet-connected build server that has the same architecture as the secure system.

[SIEGE](https://github.com/bcbi/SIEGE) takes a Julia project as input and automatically generates a sysimage (using PackageCompiler) for use in secure systems.
It also includes a Bash script that starts an offline Julia session with the new sysimage.
The script sets environment variables and accepts command-line arguments, so it can be aliased to `julia` by users.

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
0. Read through `src/SIEGE.jl` to see what's going on.
1. Replace the example project file in `env/` with the one you want to build into a sysimage.
2. While you're at it, go ahead and update the paths to Julia and SIEGE in `run_sysimage.sh`.
3. Run `main()` from `src/SIEGE.jl` on the build server to build the sysimage and depot. Any generated files will be found in `build/`.

```
pkg> activate --temp
pkg> develop Path/To/SIEGE
julia> using SIEGE
julia> main("/Path/To/SIEGE")
```

4. Upload Julia and SIEGE to the secure system.
5. Users can now use `run_sysimage.sh`. Group and permisson settings might need to be adjusted with `chgroup` and `chmod`, since many files need to be executable by users.
6. (OPTIONAL): Add to `~/.bashrc` an alias pointing to the script. It should accept command line arguments just as the Julia binary would.
```
alias julia='Path/To/run_sysimage.sh'
```

## Troubleshooting
1. Certain packages download dependencies only after they are called (lazy loading).
Try running the sysimage on the build server to see if any additional packages are downloaded at runtime.
If required dependencies are left out, these can be added manually:
    - MKL: https://github.com/JuliaLang/PackageCompiler.jl/issues/639#issuecomment-974681443

2. Some packages might just not be relocatable yet and would need to be patched.

## Related
- [Secure systems: an alternate use case for PackageCompiler.jl](https://discourse.julialang.org/t/secure-systems-an-alternate-use-case-for-packagecompiler-jl/90955?u=ashlin_harris)
- [Installing packages via an SSH SOCKS proxy on a compute cluster](https://discourse.julialang.org/t/installing-packages-via-an-ssh-socks-proxy-on-a-compute-cluster/71735?u=ashlin_harris)
