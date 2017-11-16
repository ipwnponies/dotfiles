# jiq is an IDE for writing jq
if status --is-login; and status --is-interactive; and not type -q jiq
    set -l download_path (mktemp -d)/jiq.zip

    # Download jiq to temporary path and verify checksum
    if curl --silent -L https://gobuilder.me/get/github.com/fiatjaf/jiq/cmd/jiq/jiq_master_linux-amd64.zip -o $download_path; \
        and string match -q 'c211a8ee04f520d652cbc0bc18e625a236edf60dfd53eee8572e42865535ecde*' (sha256sum $download_path)

        # Extract to ~/.local/bin
        unzip -qq -j $download_path jiq/jiq -d $HOME/.local/bin/
    end
end
