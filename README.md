# dotfiles
mkdir -p $HOME/.local/bin \ 
  && sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin init --apply git@github.com:the-commits/dotfiles.git
