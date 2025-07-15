class Fakeroot < Formula
  desc "Provide a fake root environment"
  homepage "https://tracker.debian.org/pkg/fakeroot"
  url "https://deb.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.37.1.2.orig.tar.gz"
  sha256 "959496928c8a676ec8377f665ff6a19a707bfad693325f9cc4a4126642f53224"
  license "GPL-3.0-or-later"

  # Needed to apply patches below. Remove when no longer needed.
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  on_linux do
    depends_on "libcap" => :build
  end

  # https://salsa.debian.org/clint/fakeroot/-/merge_requests/17
  patch :p0 do
    # The MR has a typo, so we use MacPorts' version.
    url "https://raw.githubusercontent.com/macports/macports-ports/0ffd857cab7b021f9dbf2cbc876d8025b6aefeff/sysutils/fakeroot/files/patch-message.h.diff"
    sha256 "6540eef1c31ffb4ed636c1f4750ee668d2effdfe308d975d835aa518731c72dc"
  end
  patch :p1 do
    url "https://gist.github.com/AdityaGarg8/55750dc7b79574ee0ac82eb1527a6b89/raw/083b5b366daff06a0c1dced944d9de3a2ff3de28/0001-Drop-INODE64-stat-wrappers-on-arm64-macOS.patch"
    sha256 "b22a07bd45c98ebc8482eca584a98e17852f5407150a0383335e67482ca691a2"
  end
  patch :p1 do
    url "https://gist.github.com/AdityaGarg8/55750dc7b79574ee0ac82eb1527a6b89/raw/083b5b366daff06a0c1dced944d9de3a2ff3de28/0002-Remove-unused-tokens-in-macOS-availability-macro-che.patch"
    sha256 "b4b2bf5e5489c439e0959f610aae77c4d26ecc255fa40c8456a9bf9ee65428af"
  end
  patch :p1 do
    url "https://gist.github.com/AdityaGarg8/55750dc7b79574ee0ac82eb1527a6b89/raw/083b5b366daff06a0c1dced944d9de3a2ff3de28/0003-Fix-endianness-detection-on-macOS.patch"
    sha256 "43bb71f54fcb0772541f0b84fc53b237d926ea7e320132831daa8edb706d3951"
  end
  patch :p1 do
    url "https://gist.github.com/AdityaGarg8/55750dc7b79574ee0ac82eb1527a6b89/raw/083b5b366daff06a0c1dced944d9de3a2ff3de28/0004-Fix-bitwise-st-mode-comparison-in-process_chmod.patch"
    sha256 "c33b9edbf4060e2c992c39a093569ec3b320c5d5298a33f964cd2466549c78ee"
  end
  patch :p1 do
    url "https://gist.github.com/AdityaGarg8/55750dc7b79574ee0ac82eb1527a6b89/raw/083b5b366daff06a0c1dced944d9de3a2ff3de28/0005-Replace-SOL_TCP-with-IPPROTO_TCP.patch"
    sha256 "1228e9dd6381eff75386a7f7e8cc79e9d940e070fe38336b98c80e4e326718b8"
  end
  def install
    system "./bootstrap" # remove when patches are no longer needed

    args = ["--disable-silent-rules"]
    args << "--disable-static" if OS.mac?

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fakeroot -v")
  end
end
