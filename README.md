# Homebrew tap for vmuc

[vmuc](https://github.com/giejqf/vmuc) runs ARM Linux virtual machines on
Apple silicon from the command line, on its own VMM over
Hypervisor.framework.

```
brew install giejqf/vmuc/vmuc
vmuc info
```

The formula builds vmuc from source, ad-hoc signs it with the hypervisor
entitlement, and installs the guest kernel and agent from the matching
release. Guest networking needs a small root helper; `vmuc sudoers` prints
how to install it. Requires macOS 15 or newer on Apple silicon.

`Formula/vmuc.rb` is rendered from `packaging/homebrew/vmuc.rb` in the
vmuc repository by its release workflow; change it there.
