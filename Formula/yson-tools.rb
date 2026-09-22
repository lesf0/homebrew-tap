# Template rendered by .github/workflows/release.yml into the homebrew tap as
# Formula/yson-tools.rb. The version, the urls and the four platform checksums
# are filled in at release time; nothing here needs editing by hand.
class YsonTools < Formula
  include Language::Python::Virtualenv

  desc "CLI tools for working with the Yandex YSON format"
  homepage "https://github.com/lesf0/yson-tools"
  version "0.4.0"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/lesf0/yson-tools/releases/download/v0.4.0/yson-tools-0.4.0-darwin-arm64.tar.gz"
      sha256 "932dca604f858dbb584bcfb0f4f07add6d4829ff87a5d45899139845b5edcb89"
    end

    on_intel do
      url "https://github.com/lesf0/yson-tools/releases/download/v0.4.0/yson-tools-0.4.0-darwin-amd64.tar.gz"
      sha256 "e0fd6b9833e76acbf67205daa17f29cb3fb28da448bca3b008269ee2295c4193"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/lesf0/yson-tools/releases/download/v0.4.0/yson-tools-0.4.0-linux-arm64.tar.gz"
      sha256 "1a87d7938b2ab8f611a0c0473a063deac0478670e3e1dd2cba3d16ed0c1a3a9d"
    end

    on_intel do
      url "https://github.com/lesf0/yson-tools/releases/download/v0.4.0/yson-tools-0.4.0-linux-amd64.tar.gz"
      sha256 "7af521e487735aac9ca85f2ba8b09c766d1b8cf6cbe3dacd24af83b91e77b913"
    end
  end

  # ysondiff shells out to jdiff, which is shipped by the jsondiff python package
  depends_on "python@3.14"

  resource "jsondiff" do
    url "https://files.pythonhosted.org/packages/35/48/841137f1843fa215ea284834d1514b8e9e20962bda63a636c7417e02f8fb/jsondiff-2.2.1.tar.gz"
    sha256 "658d162c8a86ba86de26303cd86a7b37e1b2c1ec98b569a60e2ca6180545f7fe"
  end

  # jsondiff/__init__.py imports yaml, so jdiff does not start without it
  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  def install
    bin.install "yson-convert", "ysonq", "yson-format", "ysondiff"

    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install resource("jsondiff"), resource("pyyaml")
    bin.install_symlink libexec/"bin/jdiff"
  end

  test do
    assert_equal '{"a":1}', pipe_output("#{bin}/yson-convert -m y2j -f compact", "{a=1}").strip
    assert_equal "{a=1;}", pipe_output("#{bin}/ysonq -c .", "{a=1}").strip

    (testpath/"a.yson").write("{foo=baz}")
    (testpath/"b.yson").write("{foo=bar}")
    assert_equal "{foo=[baz;bar;];}",
                 pipe_output("#{bin}/ysondiff #{testpath}/a.yson #{testpath}/b.yson -s symmetric").strip
  end
end
