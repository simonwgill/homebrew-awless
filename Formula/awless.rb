class Awless < Formula
  version = "0.0.17"
  
  desc "The Mighty CLI for AWS"
  homepage "https://github.com/wallix/awless"
  url "https://github.com/wallix/awless.git",
        :tag => version
  head "https://github.com/wallix/awless.git"

  depends_on "go" => :build
  
  bottle do
    root_url "https://github.com/wallix/homebrew-awless/releases/download/#{version}"
    cellar :any_skip_relocation
    sha256 "78bad5b5efa4a6c7182722094ac29257051125930f180a9bf863ee991b2738f5" => :sierra
  end

  def install
    ENV["GOPATH"] = buildpath
    arch = MacOS.prefer_64_bit? ? "amd64" : "x86"
    dir = buildpath/"src/github.com/wallix/awless"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # Make binary
      system "go", "run", "release.go", "-tag",version,"-brew","-arch","#{arch}", "-os","darwin"
      bin.install "awless"

      # Install bash completion
      output = Utils.popen_read("#{bin}/awless completion bash")
      (bash_completion/"awless").write output
      
      # Install zsh completion
      output = Utils.popen_read("#{bin}/awless completion zsh")
      (zsh_completion/"_awless").write output
    end
  end
  
  def caveats
      <<-EOS.undent
      
      In order to get awless completion, 
        [bash] you need to install `bash-completion` with brew.
        OR
        [zsh], add the following line to your ~/.zshrc:
          source #{HOMEBREW_PREFIX}/share/zsh/site-functions/_awless
      EOS
  end

  test do
    run_output = shell_output("#{bin}/awless --help 2>&1")
    assert_match "Awless is a powerful command line tool to inspect, sync and manage your infrastructure", run_output
  end
end
