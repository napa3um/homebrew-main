class SdCpp < Formula
  desc "Stable Diffusion in pure C/C++ (llama.cpp-style, GGML backend)"
  homepage "https://github.com/leejet/stable-diffusion.cpp"
  version "master-929-3f8527a"
  # arm64 (Apple Silicon) only; releases are not notarized, Quarantine is stripped below
  url "https://github.com/leejet/stable-diffusion.cpp/releases/download/master-929-3f8527a/sd-master-3f8527a-bin-Darwin-macOS-26.6.2-arm64.zip"
  sha256 "1c8ee6c8e413e3335b1223bbc657ea5d86dae1819f8426a98b84c265587eb192"
  license "MIT"

  def caveats
    <<~EOS
      Prebuilt upstream binaries are NOT notarized by Apple. This formula
      clears the quarantine attribute on install; run `sd-cli` at your own trust
      in upstream CI builds.
    EOS
  end

  def install
    files = Dir["**/*"].select { |f| File.file?(f) }
    bins = files.select { |f| File.executable?(f) || f.end_with?(".dylib") }
    odie "no executables found in archive" if bins.empty?
    bin.install bins
    doc.install Dir["*LICENSE*"] if Dir["*LICENSE*"].any?
  end

  def post_install_steps
    # brew's Verified download makes files non-writable; xattr needs write access
    Dir[bin/"*"].each do |f|
      FileUtils.chmod("u+w", f)
      system "/usr/bin/xattr", "-d", "com.apple.quarantine", f rescue nil
    end
  end

  test do
    assert_match "usage", shell_output("#{bin}/sd-cli --help 2>&1", 0).downcase
  end
end
