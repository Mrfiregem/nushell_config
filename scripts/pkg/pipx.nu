# List installed packages
export def list [--short(-s)] {
    if $short {
        ^pipx list --short | collect { lines | parse '{name} {version}' }
    } else {
        ^pipx list --json
        | from json | get venvs
        | transpose name value
        | update value {
            get metadata
            | {
                binaries: $in.main_package.apps
                dependencies: ($in.main_package.app_paths_of_dependencies | columns)
                version: $in.main_package.package_version
                python: $in.python_version
            }
        } | flatten value
    }
}

# Print a list of environment variables and paths used by pipx
export def environment [--value(-V): string] {
    if ($value | is-empty) {
        ^pipx environment | lines
        | split list ''
        | drop nth 0 2
        | each { parse '{name}={value}' | transpose -rd }
        | transpose name user default
        | update cells -c [user default] {|s| if $s == null {''} else {$s} }
    } else {
        ^pipx environment --value $value | into string
    }
}

# Install and execute apps from Python packages
export extern main [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --version # Print version and exit
]

# Install a package
export extern install [
    ...package_spec: string # Package name(s) or pip installation spec(s)
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --include-deps # Include apps of dependent packages
    --force(-f) # Modify existing venv and files
    --suffix: string # Optional suffix for venv and executable names
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
    --preinstall: string # package to be installed into venv before installing the main package
    --system-site-packages # Give the venv access to the system site-packages dir
    --index-url(-i): string # Base URL of Python Package Index
    --editable(-e) # Install a project in editable mode
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# Installs all the packages according to spec metadata file
export extern install-all [
    spec_metadata_file: path # Spec metadata file generated from pipx list --json
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --force(-f) # Modify existing venv and files
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
    --system-site-packages # Give the venv access to the system site-packages dir
    --index-url(-i): string # Base URL of Python Package Index
    --editable(-e) # Install a project in editable mode
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# Uninstall injected packages from an existing venv
export extern uninject [
    package: string # Name of the existing pipx-managed venv to inject into
    ...dependencies: string # The package names to uninject from the venv
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --leave-deps # Only uninstall the main injected package but leave its dependencies installed
]

# Install packages into an existing venv
export extern inject [
    package: string # Name of the existing pipx-managed venv to inject into
    ...dependencies: string # The packages to inject into the venv (name or pip package spec)
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --requirement(-r): path # file containing the packages to inject into the venv
    --include-apps # Add apps from the injected packages onto your PATH
    --include-deps # Include apps of dependent packages (for --include-apps)
    --system-site-packages # Give the venv access to the system site-packages dir
    --index-url(-i): string # Base URL of Python Package Index
    --editable(-e) # Install a project in editable mode
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
    --force(-f) # Modify existing venv and files
    --with-suffix # Add the suffix (if given) of the venv to the packages to inject
]

# Upgrade a package
export extern upgrade [
    ...packages: string # Package names(s) to upgrade
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --include-injected # Also upgrade packages injected into the main app's environment
    --force(-f) # Modify existing venv and files
    --system-site-packages # Give the venv access to the system site-packages dir
    --index-url(-i): string # Base URL of Python Package Index
    --editable(-e) # Install a project in editable mode
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
]

# Upgrades all packages within their venvs by running 'pip install --upgrade PACKAGE'
export extern upgrade-all [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --include-injected # Also upgrade packages injected into the main app's environment
    --skip: string # Skip these packages
    --force(-f) # Modify existing venv and files
]

# Upgrade shared libraries
export extern upgrade-shared [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# Uninstall a package
export extern uninstall [
    package: string # Package name
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
]

# Uninstall all packages
export extern uninstall-all [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
]

# Reinstall a package
export extern reinstall [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
]

# Reinstall all packages
export extern reinstall-all [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
    --skip: string # Skip these packages
]

# Interact with interpreters managed by pipx
export extern interpreter [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
]

# List available interpreters
export extern "interpreter list" [
    --help(-h) # Show help message and exit
]

# Prune unused interpreters
export extern "interpreter prune" [
    --help(-h) # Show help message and exit
]

# Upgrade installed interpreters to the latest available micro/patch version
export extern "interpreter upgrade" [
    --help(-h) # Show help message and exit
]

# Download the latest version of a package to a temporary venv, then run an app from it
export extern run [
    app: string # App name
    ...rest: string # Arguments passed to app
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --no-cache # Do not reuse cached venv if it exists
    --path # Interpret app name as a local path
    --pypackages # Require app to be run from local __pypackages__ directory
    --spec: string # The package name or specific installation source passed to pip
    --python: string # Python to install with
    --fetch-missing-python # fetch a standalone python build from GitHub if the specified python version is not found
    --system-site-packages # Give the venv access to the system site-packages dir
    --index-url(-i): string # Base URL of Python Package Index
    --editable(-e) # Install a project in editable mode
    --pip-args: string # Arbitrary pip arguments to pass directly to pip install/upgrade commands
]

# Run pip in an existing pipx-managed venv
export extern runpip [
    package: string # Name of the existing pipx-managed venv to run pip in
    ...pipargs: string # Arguments to forward to pip command
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
]

# Ensure directories necessary for pipx operation are in your PATH environment variable
export extern ensurepath [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
    --force(-f) # Add text to your shell's config file even if already added
]

# Print instructions on enabling shell completions for pipx
export extern completions [
    --help(-h) # Show help message and exit
    --quiet(-q) # Give less output
    --verbose(-v) # Give more output
]
