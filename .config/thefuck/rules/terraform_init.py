import re


def match(command):
    return any(
        [
            "terraform init" in command.output.lower()
            and "terraform plan" in command.script,
            "this module is not yet installed" in command.output.lower(),
            "initialization required" in command.output.lower(),
            "required plugins are not installed" in command.output.lower(),
        ]
    )


def get_new_command(command):
    prefix, tf_command, _ = command.script.partition("terraform")
    if tf_command:
        return f"{prefix} terraform init; and {command.script}"
    else:
        raise ValueError("Matcher matching against unknown terraform command")
