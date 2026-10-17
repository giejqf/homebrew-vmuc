# Homebrew tap for vmuc

[vmuc](https://github.com/giejqf/vmuc) runs ARM Linux virtual machines on
Apple silicon from the command line, on its own VMM over
Hypervisor.framework.

```
brew install giejqf/vmuc/vmuc
vmuc info
```

Requires macOS 15 or newer on Apple silicon. On those, the install pours
a bottle: vmuc built, ad-hoc signed with the hypervisor entitlement, and
packed with the guest kernel and agent of the matching release, so
nothing is compiled. Guest networking needs a small root helper; `vmuc
sudoers` prints how to install it.

`Formula/vmuc.rb` is rendered from `packaging/homebrew/vmuc.rb` in the
vmuc repository by its release workflow; change it there. Bottles come
from this repository's CI: `brew test-bot` builds and tests them on a
pull request, and the `brew pr-pull` workflow publishes them
(`packaging/homebrew/README.md` in vmuc has the release steps).
