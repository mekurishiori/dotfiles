#!/usr/bin/env python
# neovim-autocd.py
import neovim
import os

nvim = neovim.attach('socket', os.environ['NVIM_LISTEN_ADDRESS'])
nvim.vars['__autocd_cwd'] = os.getcwd()
nvim.command('execute "lcd" fnameescape(g:__autocd_cwd)')
del nvim.vars['__autocd_cwd']