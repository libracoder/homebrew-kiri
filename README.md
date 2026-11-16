# Kiri for Homebrew

The Homebrew tap for [Kiri](https://runkiri.com), the container runtime that works with the Docker CLI, Compose and buildx.

```sh
brew install --cask libracoder/kiri/kiri
```

This installs `Kiri.app`, the same signed app as the DMG on the [releases page](https://github.com/libracoder/kiri/releases). The app keeps itself up to date.

To remove Kiri:

```sh
brew uninstall --cask kiri         # the app
brew uninstall --zap --cask kiri   # the app, Kiri's setup, and its images and volumes
```

The cask is on its way to Homebrew's main list too. Once it lands there, `brew install --cask kiri` will work without this tap.

Problems with Kiri itself go to [libracoder/kiri](https://github.com/libracoder/kiri/issues). Problems with the cask go here.
