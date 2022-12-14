module SIEGE

export main

using Pkg
using PackageCompiler

function main(path=pwd(), check=true)

	# Compiler check
	if check
		@info("Performing compiler check.\nRun with check=false to disable this compiler check")
		# Assuming compiler is gcc
		versionStatement = read(`gcc --version`, String)
		version = match(r"\d*?\.\d*?\.\d*", versionStatement)
		if isnothing(version)
			@error("Could not determine compiler version!")
		elseif VersionNumber(version.match) < v"9.0"
			@error("No compatable gCC version found!\n(At minimum v9.0 is required)", version.match)
			return
		else
			@info("Compatable gCC version found:", version.match)
		end
	end

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
	new_environment["JULIA_PROJECT"]=project_directory

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

	# Create sysimage 
	create_sysimage(package_list;
		sysimage_path=my_sysimage,
		project=project_directory,
		incremental=true,
		filter_stdlibs=false,
		include_transitive_dependencies=true,
	)

	return
end

end # module SIEGE
