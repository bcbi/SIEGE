module SIEGE

export main

using Pkg
using PackageCompiler

function main( path = pwd() )

	# Set paths
	parent_directory = path
	@info("Working in:",parent_directory)
	project_directory = joinpath(parent_directory, "env")
	build_directory = joinpath(parent_directory, "build")

	my_depot = joinpath(build_directory, "depot")
	my_sysimage = joinpath(build_directory, "sysimage.so")

	if isdir(my_depot)
		@info("Depot already exists; using existing depot", my_depot)
	end

	# Set up new environment
	new_environment = copy(ENV)
	delete!(new_environment, "JULIA_LOAD_PATH");
	new_environment["JULIA_DEPOT_PATH"] = my_depot
	new_environment["JULIA_PROJECT"] = project_directory

	run(setenv(`$(Base.julia_cmd()) -e "import Pkg; Pkg.instantiate(); Pkg.precompile()"`, new_environment))

	# Get all packages from Project.toml
	all_packages = String[]
	for (uuid, dep) in Pkg.dependencies()
		dep.is_direct_dep || continue
		dep.version === nothing && continue
		push!(all_packages,dep.name)
	end

	# Remove unneeded packages
	do_not_include = ["PackageCompiler","SIEGE"]
	package_list = filter(x -> x ∉ do_not_include, all_packages)

	# Generate precompile file from package tests
	precompile_file = tempname()
	for package in package_list
		write(precompile_file, "import $package\n")
	end
	write(precompile_file, "\n")
	for package in package_list
		write(precompile_file, "include(joinpath(pkgdir($package), \"test\", \"runtests.jl\"))\n")
	end

	# Create sysimage 
	create_sysimage(package_list;
		sysimage_path = my_sysimage,
		project = project_directory,
		incremental = true,
		filter_stdlibs = false,
		include_transitive_dependencies = true,
		precompile_execution_file = precompile_file,
	)

	# Delete local files from build depot
	rm(joinpath(my_depot, "compiled"), recursive = true, force = true)
	rm(joinpath(my_depot, "logs"), recursive = true, force = true)
	rm(joinpath(my_depot, "registries", "General.tar.gz"), force = true)
	rm(joinpath(my_depot, "registries", "General.toml"), force = true)

	return
end

end # module SIEGE
