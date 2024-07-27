export extern main [
    --version(-v) # Display the version of the tool
    --info # Display general info of the tool
    --help(-?) # Shows help about the selected command
    --wait # Prompts the user to press any key before exiting
    --logs # Open the default logs location
    --verbose # Enables verbose logging for winget
    --nowarn # Suppresses warning outputs
    --disable-interactivity # Disable interactive prompts
    --proxy # Set a proxy to use for this execution
    --no-proxy # Disable the use of proxy for this execution
]

export use search.nu
export use list.nu