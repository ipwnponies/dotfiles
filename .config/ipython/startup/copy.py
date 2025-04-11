def copy(output: object) -> None:
    """It's like browser copy, but for ipython"""
    import subprocess
    import platform

    os_name = platform.system()

    match os_name:
        case "Darwin":
            # macOS
            command = ["pbcopy"]
        case "Linux":
            if "microsoft" in platform.uname().release.lower():
                # WSL
                command = ["clip.exe"]
            else:
                # Linux
                command = ["xclip", "-selection", "clipboard"]
        case "Windows":
            # Windows
            command = ["clip"]
        case _:
            raise NotImplementedError(f"Clipboard copy not supported on {os_name}")

    subprocess.run(command, input=output, text=True, check=True)
