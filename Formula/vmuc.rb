# Homebrew formula for vmuc. Lives in the tap repository as
# Formula/vmuc.rb; this copy is the source of truth. The release workflow
# fills in the version and checksums with packaging/homebrew/render.sh
# and attaches the result to the draft release; the tap's CI builds the
# bottles and adds the `bottle do` block (packaging/homebrew/README.md).
class Vmuc < Formula
  desc "ARM Linux VMs on Apple silicon with host-returnable guest memory"
  homepage "https://github.com/giejqf/vmuc"
  url "https://github.com/giejqf/vmuc/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a560210bcaeeeb5472dc4dc99ca4357829d36dccd1399077f2d004c0fbe09707"
  license "Apache-2.0"
  # No `head`: the guest kernel and agent below come from a release, and a
  # build of main would pair new host code with an older agent.

  bottle do
    root_url "https://github.com/giejqf/homebrew-vmuc/releases/download/vmuc-0.1.0"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "890e8ab8f06dda2549be5145321e1de3b0adff159e76b685c88b7c3c4a7fc28a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "05a6dbf1a43d92f92b95916dd5948c7068018688a0c7dee0bb56a8485eb01e1d"
  end

  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on macos: :sequoia

  # Built on Linux by the release workflow (the kernel passes a QEMU boot
  # test there) and pinned here, so an install is reproducible and works
  # offline afterwards. Homebrew's Rust has no musl target, so the static
  # guest agent is a release asset too.
  resource "kernel" do
    url "https://github.com/giejqf/vmuc/releases/download/v0.1.0/vmuc-kernel-0.1.0-arm64.img"
    sha256 "99e214051dfa8d8b6492c06ec197f9f598a0b66fb6d9befbb06e4863bb73d765"
  end

  resource "agent" do
    url "https://github.com/giejqf/vmuc/releases/download/v0.1.0/vmuc-agent-0.1.0-aarch64-linux-musl"
    sha256 "936a7c293882003232a07ef2c1c529836b21e5626874ecab81307f9d962c0d56"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/vmuc-cli")
    # vmuc-vmnet-helper: `vmuc sudoers` shows how to copy it somewhere
    # root-owned; sudo never runs this user-writable copy.
    system "cargo", "install", *std_cargo_args(path: "crates/vmuc-net")
    # Hypervisor.framework needs the entitlement; an ad-hoc signature is
    # enough and survives Homebrew's relocation (it re-signs with
    # --preserve-metadata=entitlements).
    system "codesign", "--force", "--sign", "-",
           "--entitlements", "vmuc.entitlements", bin/"vmuc"
    # Paths vmuc looks in: <prefix>/share/vmuc/{kernel/Image,vmuc-agent,templates}.
    resource("kernel").stage do
      (pkgshare/"kernel").install "vmuc-kernel-#{version}-arm64.img" => "Image"
    end
    resource("agent").stage do
      pkgshare.install "vmuc-agent-#{version}-aarch64-linux-musl" => "vmuc-agent"
    end
    chmod 0755, pkgshare/"vmuc-agent"
    (pkgshare/"templates").install Dir["guest/templates/*"]
  end

  def caveats
    <<~EOS
      vmuc needs macOS 15 or newer on Apple silicon. Check the host and
      the install with:
        vmuc info
      Guest networking through vmnet needs a small root helper and a
      sudoers rule; `vmuc sudoers` prints the commands. Without it,
      instances boot without a NIC and ssh, file sharing and port
      forwarding still work.
    EOS
  end

  test do
    assert_match "vmuc #{version}", shell_output("#{bin}/vmuc --version")
    assert_match "com.apple.security.hypervisor",
                 shell_output("codesign -d --entitlements - #{bin}/vmuc 2>&1")
    assert_match "ready:       yes", shell_output("#{bin}/vmuc info")
  end
end
