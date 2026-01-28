[1;35m# Keyboard Shortcuts Cheatsheet[0m                                                            Press [1;33mq[0m to close

┌─────────────────────────────────────────────────────┬─────────────────────────────────────────────────────┐
│  [1;36mHELIX MODES[0m  (selection-first editing)             │  [1;36mHELIX MOTIONS[0m                                      │
├─────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│  [1;33mEsc[0m         Normal mode                            │  [1;33mh/j/k/l[0m     Left / Down / Up / Right               │
│  [1;33mi[0m           Insert before selection                │  [1;33mw/b[0m         Select next/prev word                  │
│  [1;33ma[0m           Insert after selection                 │  [1;33me[0m           Select to end of word                  │
│  [1;33mo/O[0m         New line below/above                   │  [1;33m0/$[0m         Start / End of line                    │
│  [1;33mv[0m           Select mode (extend)                   │  [1;33mgg/ge[0m       Top / Bottom of file                   │
│  [1;33mx[0m           Select line (repeat to extend)         │  [1;33mCtrl+d/u[0m    Page down / Page up                    │
│  [1;33mSpace[0m       Open picker/command palette            │  [1;33m/pattern[0m    Search forward                         │
│  [1;33m:[0m           Command mode                           │  [1;33mn/N[0m         Next / Previous match                  │
│  [1;33m:w :q :wq[0m   Save / Quit / Save+Quit                │  [1;33mf/t{char}[0m   Find/Till character                    │
│  [1;33md/c/y[0m       Delete/Change/Yank selection           │  [1;33mmm/ms/md[0m    Surround add/select/delete             │
└─────────────────────────────────────────────────────┴─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┬─────────────────────────────────────────────────────┐
│  [1;36mGHOSTTY[0m (Terminal)                                 │  [1;36mZSH[0m (Shell)                                        │
├─────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│  [1;33mcmd + t[0m           New tab                          │  [1;33mCtrl + r[0m      Fuzzy search history (fzf)           │
│  [1;33mcmd + n[0m           New window                       │  [1;33mCtrl + t[0m      Fuzzy file finder                    │
│  [1;33mcmd + w[0m           Close tab/pane                   │  [1;33malt + c[0m       Fuzzy cd into directory              │
│  [1;33mcmd + shift + [][0m  Previous/next tab                │  [1;33mTab[0m           Autocomplete (fzf-tab)               │
│  [1;33mcmd + d[0m           Split right                      │  [1;33mCtrl + a/e[0m    Beginning / End of line              │
│  [1;33mcmd + shift + d[0m   Split down                       │  [1;33mCtrl + w[0m      Delete word backward                 │
│  [1;33mcmd + [][0m          Navigate splits                  │  [1;33mCtrl + u/k[0m    Delete to beginning / end            │
│  [1;33mcmd + k[0m           Clear screen                     │  [1;33mCtrl + l[0m      Clear screen                         │
│  [1;33mcmd + ,[0m           Open config                      │  [1;33m!![0m            Repeat last command                  │
│                                                     │  [1;33m!$[0m            Last argument of prev command        │
└─────────────────────────────────────────────────────┴─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┬─────────────────────────────────────────────────────┐
│  [1;36mZED[0m (Editor - Vim Mode)                            │  [1;36mFILE NAVIGATION[0m (eza)                              │
├─────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
│  [1;33mjk[0m              Exit insert mode (custom)          │  [1;33mls / l[0m      eza with icons + git status            │
│  [1;33mgd / gD[0m         Go to definition / declaration     │  [1;33mla[0m          Detailed list (all files)              │
│  [1;33mgy / gs[0m         Go to type / symbol                │  [1;33mlt[0m          Tree view (2 levels)                   │
│  [1;33mctrl + hjkl[0m     Navigate panes                     │  [1;33mlta[0m         Tree view with hidden files            │
│  [1;33mss / sv[0m         Split right / down                 │  [1;33mtree[0m        Tree view (3 levels)                   │
│  [1;33mShift + h/l[0m     Previous / next buffer             │  [1;33mcat[0m         bat with syntax highlighting           │
│  [1;33mShift + q[0m       Close buffer                       │                                                     │
│  [1;33mspace space[0m     File finder                        ├─────────────────────────────────────────────────────┤
│  [1;33mspace e[0m         Toggle project panel               │  [1;36mGIT ALIASES[0m                                        │
│  [1;33mys / cs / ds[0m    Surround add/change/delete         ├─────────────────────────────────────────────────────┤
│  [1;33mgc / gcc[0m        Comment (visual / line)            │  [1;33mg[0m          git                                     │
│  [1;33m]d / [d[0m         Next / prev diagnostic             │  [1;33mga[0m         git add                                 │
│  [1;33mgl / ga[0m         Select next / all occurrences      │  [1;33mgaa[0m        git add --all                           │
│  [1;33mctrl+x ctrl+a[0m   Inline AI assistant                │  [1;33mgc[0m         git commit -m                           │
│                                                     │  [1;33mgs[0m         git status                              │
│                                                     │  [1;33mgp / gpl[0m   git push / git pull                     │
│                                                     │  [1;33mgl[0m         git log --oneline --graph               │
│                                                     │  [1;33mgco[0m        git checkout                            │
└─────────────────────────────────────────────────────┴─────────────────────────────────────────────────────┘
