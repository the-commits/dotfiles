# dotfiles
mkdir -p $HOME/.local/bin \ 
  && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply https://github.com/the-commits/dotfiles.git
