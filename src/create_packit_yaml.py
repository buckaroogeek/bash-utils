#!/usr/bin/env python3

import os
import re
import argparse
import subprocess
import textwrap

def parse_spec_file(spec_file_path):
    """Parses the .spec file to find the package name and upstream URL."""
    url = None
    name = None

    with open(spec_file_path, 'r') as file:
        for line in file:
            if line.startswith("Name:"):
                name = line.split(":")[1].strip()
            # The URL is often in a comment line
            elif line.startswith("#"):
                match = re.search(r'https?://\S+', line)
                if match:
                    url = match.group(0)
            if name and url:
                break

    return name, url

def generate_packit_yaml(name, url, add_go_actions):
    """Generates the content for the .packit.yaml file."""

    yaml_content = textwrap.dedent(f"""\
        ---
        downstream_package_name: {name}
        upstream_project_url: {url}
        upstream_tag_template: "v{{version}}"

        jobs:
          - job: pull_from_upstream
            trigger: release
            dist_git_branches:
              rawhide: {{}}

          - job: koji_build
            trigger: commit
            dist_git_branches:
              - rawhide
    """)

    if add_go_actions:
        actions_block = textwrap.dedent("""\
            actions:
              post-modifications:
                - |
                  sh -xeuc "
                    cd $PACKIT_DOWNSTREAM_REPO
                    export GOTOOLCHAIN=local+auto
                    spec="$PACKIT_DOWNSTREAM_PACKAGE_NAME.spec"
                    go_vendor_archive create --config go-vendor-tools.toml "$spec"
                    go_vendor_license \\
                      --config go-vendor-tools.toml \\
                      --path "$spec" \\
                      report \\
                      --verify-spec \\
                      --autofill=auto
                  "
            create_sync_note: false
        """)
        yaml_content += actions_block

    return yaml_content

def main():
    """Main function to parse arguments and create the file."""
    parser = argparse.ArgumentParser(description="Generate .packit.yaml file for Fedora packaging.")
    parser.add_argument("--name", help="Downstream package name (e.g., gitleaks).")
    parser.add_argument("--url", help="Upstream project URL.")
    args = parser.parse_args()

    current_dir = os.getcwd()
    default_name = os.path.basename(current_dir)

    # Determine .spec file path using the directory name as a default
    specfile_path = os.path.join(current_dir, f"{default_name}.spec")

    # Use the provided name, otherwise default to the current directory's name
    name = args.name if args.name else default_name

    # Use the provided URL, otherwise try to parse it from the .spec file
    if args.url:
        url = args.url
    else:
        if os.path.isfile(specfile_path):
            _, url_from_spec = parse_spec_file(specfile_path)
            if not url_from_spec:
                print(f"Error: Could not find a URL in {specfile_path}. Please provide one with --url.")
                return
            url = url_from_spec
        else:
            print(f"Error: {specfile_path} not found and no URL provided via --url.")
            return

    # Check if we need to add the Go vendoring actions
    add_go_actions = os.path.isfile("go-vendor-tools.toml")
    if add_go_actions:
        print("Found 'go-vendor-tools.toml', adding Go-specific actions.")

    # Generate .packit.yaml content
    yaml_content = generate_packit_yaml(name, url, add_go_actions)

    # Write the content to the .packit.yaml file
    packit_yaml_path = ".packit.yaml"
    with open(packit_yaml_path, "w") as yaml_file:
        yaml_file.write(yaml_content)

    print(f"âœ… Successfully created '{packit_yaml_path}'.")

    # Run 'packit validate' to check the generated file
    print("Running 'packit validate'...")
    try:
        subprocess.run(["packit", "validate", packit_yaml_path], check=True, capture_output=True, text=True)
        print("âœ… Validation successful.")
    except FileNotFoundError:
        print("Warning: 'packit' command not found. Skipping validation.")
    except subprocess.CalledProcessError as e:
        print(f"Error: Validation of {packit_yaml_path} failed.")
        print(e.stderr)

if __name__ == "__main__":
    main()

