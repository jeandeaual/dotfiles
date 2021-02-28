# Make sure we’re using the latest Homebrew
update

# Upgrade any already-installed formulae
upgrade

# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
install coreutils
# Install some other useful utilities like `sponge`
install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
install findutils
# Install Bash 4
install bash
# Install zsh
install zsh

# Install wget with IRI support
install wget --enable-iri

# Install other useful binaries
install ack
install the_silver_searcher
install git
install mercurial
install imagemagick --with-webp
install lynx
install node
install tree
install p7zip
install tmux

install homebrew/versions/lua52

install macvim --override-system-vim --custom-icons --with-luajit
install emacs --cocoa --japanese --srgb --with-gnutls --with-x
link --force macvim emacs

# Remove outdated versions from the cellar
cleanup
