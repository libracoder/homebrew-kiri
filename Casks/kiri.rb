cask "kiri" do
  arch arm: "arm64", intel: "x86_64"

  version "0.2.1"
  sha256 arm:   "c42c518eb6a4efcb995b52b987b83e848028a020eef5872e0ac16a1c7827fffa",
         intel: "66e5e9f6255ba109e1740078994d8346fbce3c1d7f77075699f3f7f6b9314cff"

  url "https://github.com/libracoder/kiri/releases/download/v#{version}/Kiri-#{version}-#{arch}.dmg"
  name "Kiri"
  desc "Container runtime compatible with the Docker CLI, Compose and buildx"
  homepage "https://runkiri.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "Kiri.app"

  uninstall launchctl: "dev.kiri.daemon",
            quit:      "dev.kiri.app"

  # `kiri setup --uninstall` takes back what `kiri setup` added: the PATH lines,
  # the docker context and builder, /var/run/docker.sock, the resolver and
  # /usr/local/bin/kiri. Only on zap, as Homebrew runs `uninstall` on reinstall.
  # It runs first, in one pass; `launchctl` and `delete` are the backup.
  # By the time zap runs, Homebrew may already have moved Kiri.app out of the
  # Applications folder into its own copy, so run whichever kiri is there.
  zap early_script: {
        executable:   "/bin/sh",
        args:         [
          "-c",
          'for k in "$@"; do [ -x "$k" ] && exec "$k" setup --uninstall; done',
          "sh",
          "#{appdir}/Kiri.app/Contents/MacOS/kiri",
          "#{staged_path}/Kiri.app/Contents/MacOS/kiri",
        ],
        must_succeed: false,
      },
      launchctl:    [
        "dev.kiri.docker-socket",
        "dev.kiri.usb",
      ],
      delete:       [
        "/etc/resolver/kiri.local",
        "/Library/PrivilegedHelperTools/dev.kiri.usb",
        "/Library/PrivilegedHelperTools/dev.kiri.usb.source",
      ],
      trash:        [
        "~/.kiri",
        "~/Library/Application Support/Kiri",
        "~/Library/Caches/dev.kiri.app",
        "~/Library/Caches/Kiri",
        "~/Library/LaunchAgents/dev.kiri.daemon.plist",
        "~/Library/WebKit/dev.kiri.app",
      ]

  caveats <<~EOS
    `brew reinstall` and `brew upgrade --greedy` stop the Kiri engine, and it
    won't start at login until you open Kiri again.
  EOS
end
