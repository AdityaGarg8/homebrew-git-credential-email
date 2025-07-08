class Makepkg < Formula
  desc "Compile and build packages suitable for installation with pacman"
  homepage "https://wiki.archlinux.org/index.php/makepkg"
  url "https://gitlab.archlinux.org/pacman/pacman.git",
      tag:      "v7.0.0",
      revision: "138cbae58448b7fde90335526add3029875784ee"
  license "GPL-2.0-or-later"
  head "https://gitlab.archlinux.org/pacman/pacman.git", branch: "master"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "bash"
  depends_on "libarchive"
  depends_on "openssl@3"

  uses_from_macos "m4" => :build
  uses_from_macos "python" => :build
  uses_from_macos "libxslt"

  on_sonoma :or_older do
    depends_on "coreutils" => :test # for md5sum
  end

  on_linux do
    depends_on "gettext"
  end

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    args = %W[
      -Dmakepkg-template-dir=#{share}/makepkg-template
      -Dsysconfdir=#{etc}
      -Dlocalstatedir=#{var}
      -Ddoc=disabled
    ]
    args << "-Di18n=false" if OS.mac?

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"PKGBUILD").write <<~EOS
      pkgname=androidnetworktester
      pkgname=test
      source=(https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/androidnetworktester/10kb.txt)
      pkgrel=0
      pkgver=0
      md5sums=('e232a2683c04881e292d5f7617d6dc6f')
    EOS
    assert_match "md5sums=('e232a2683c0", pipe_output("#{bin}/makepkg -dg 2>&1")
  end
end
