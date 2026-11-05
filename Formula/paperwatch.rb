class Paperwatch < Formula
  include Language::Python::Virtualenv

  desc "Automatically rename downloaded scientific papers using DOI/arXiv metadata"
  homepage "https://github.com/loukesio/paperwatch"
  url "https://github.com/loukesio/paperwatch/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "2254e86aacf9effa289cb21512e94a84ff3e8ac9b11a11c3e0c97b1b63f9aa38"
  license "MIT"
  head "https://github.com/loukesio/paperwatch.git", branch: "main"

  depends_on "python@3.14"

  resource "pypdf" do
    url "https://files.pythonhosted.org/packages/06/28/081f1cbcca7042441dafc8de00f48ba60853f89e5bff92c5f26477346d81/pypdf-6.21.2.tar.gz"
    sha256 "0a3e1c5c886a1be03646c16a04827cc166c2a0575c971b26a4bf89686551c2d4"
  end

  resource "watchdog" do
    url "https://files.pythonhosted.org/packages/db/7d/7f3d619e951c88ed75c6037b246ddcf2d322812ee8ea189be89511721d54/watchdog-6.0.0.tar.gz"
    sha256 "9ddf7c82fda3ae8e24decda1338ede66e1c99883db93711d8fb941eaa2d8c282"
  end

  def install
    virtualenv_install_with_resources
  end

  service do
    run [opt_bin/"paperwatch", "watch"]
    keep_alive true
    log_path var/"log/paperwatch.log"
    error_log_path var/"log/paperwatch.log"
  end

  def caveats
    <<~EOS
      Start watching ~/Downloads now and at every login:
        brew services start paperwatch

      Settings: run `paperwatch config --show`.

      macOS protects the Downloads folder. If the log
        #{var}/log/paperwatch.log
      says "no permission", add the Python binary it names under
      System Settings > Privacy & Security > Full Disk Access.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/paperwatch --version")
    (testpath/"not-a-paper.pdf").write "<html>login</html>"
    assert_match "not a PDF", shell_output("#{bin}/paperwatch rename #{testpath}/not-a-paper.pdf 2>&1", 1)
  end
end
