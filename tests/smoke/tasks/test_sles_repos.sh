#!/bin/bash

set -o pipefail -o errtrace -o errexit -o nounset -o functrace

traperror() {
    local el=${1:=??} ec=${2:=??} lc="$BASH_COMMAND"
    errorexit "ERROR in $(basename $0) : $el error $ec : $lc" ${2:=1}
}
trap 'traperror ${LINENO} ${?}' ERR

errorexit() {
    echo >&2 "$1"
    if [ -z ${2+x} ] ; then
        exit 1
    else
        exit $2
    fi
}

main() {
    # Only test on SLES/SUSE systems
    if [[ ! -f /etc/os-release ]]; then
        echo "Not a standard Linux system, skipping test"
        exit 0
    fi
    
    source /etc/os-release
    if [[ "$ID" != "sles" && "$ID" != "suse" ]]; then
        echo "Not a SLES/SUSE system (ID=$ID), skipping test"
        exit 0
    fi
    
    echo "Testing SLES repository configuration..."
    
    # Test 1: Check that zypper repos are configured
    if ! zypper lr >/dev/null 2>&1; then
        errorexit "zypper lr command failed" 1
    fi
    
    repo_count=$(zypper lr 2>/dev/null | grep -c '|' || true)
    if [[ $repo_count -eq 0 ]]; then
        errorexit "No repositories configured in zypper" 1
    fi
    echo "✓ Repositories are configured ($repo_count found)"
    
    # Test 2: Verify opensuse-leap-fallback repo exists (for unregistered images)
    if zypper lr 2>/dev/null | grep -q 'opensuse-leap-fallback'; then
        echo "✓ opensuse-leap-fallback repository found (unregistered SLES image detected)"
        
        # Test 3: Verify the repo is enabled and has packages
        if ! zypper lr -u 2>/dev/null | grep -q 'opensuse-leap-fallback.*Yes'; then
            errorexit "opensuse-leap-fallback repository exists but is not enabled" 1
        fi
        echo "✓ opensuse-leap-fallback repository is enabled"
    else
        echo "✓ No fallback repo (properly registered SLES image detected)"
    fi
    
    # Test 4: Verify critical packages are available (test package search functionality)
    echo "Testing package availability..."
    if ! zypper search --match-exact openssh-server >/dev/null 2>&1; then
        errorexit "Package search failed - openssh-server not found" 1
    fi
    echo "✓ Package search works (openssh-server found)"
    
    # Test 5: For unregistered systems, verify Java packages are available
    if zypper lr 2>/dev/null | grep -q 'opensuse-leap-fallback'; then
        if ! zypper search 'java*openjdk' 2>/dev/null | grep -q 'java'; then
            errorexit "Java OpenJDK packages not available in repositories" 1
        fi
        echo "✓ Java OpenJDK packages are available"
    fi
    
    echo "All SLES repository tests passed!"
}

main "$@"
