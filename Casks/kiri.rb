cask "kiri" do
  arch arm: "arm64", intel: "x86_64"

  version "0.2.2"
  sha256 arm:   "0f0ed39fc08f971c33ead60371c9d58768d993a853407e136f63f62a7edc9864",
         intel: "f78299a131d28801bcdfafd4bc0af8737441181d217110ee955ce251691d83d9"

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
