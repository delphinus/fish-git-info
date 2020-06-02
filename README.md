# fish-git-info

<img width="645" alt="スクリーンショット 0002-06-02 19 53 16" src="https://user-images.githubusercontent.com/1239245/83512189-d3ce7380-a50a-11ea-80ff-6277cb12ad28.png">

Yet another fork of the git prompt in [prezto][] for [fish][].

[prezto]: https://github.com/sorin-ionescu/prezto
[fish]: https://fishshell.com

## What's this?

This is a port of the git prompt from [prezto][]. It can indicate almost the
same number of features from the original one. And you can customize the format
freely.

## How to use

### with [fisher][] (recommended)

[fisher]: https://github.com/jorgebucaran/fisher

1. add this

   ```fish
   fisher add delphinus/fish-git-info
   ```

2. (optional but **highly recommended**) add [fish-async-prompt][].

   ```fish
   fisher add acomagu/fish-async-prompt
   ```

3. add to call this anywhere you like, such as in `fish-right-prompt`.

   ```fish
   vim ~/.config/fish/functions/fish_right_prompt.fish
   ```

   ```fish
   function fish_right_prompt
     __git_info  # <-- add this line
   end
   ```

[fish-async-prompt]: https://github.com/acomagu/fish-async-prompt

### manual

1. clone this repo
2. link the script

   ```fish
   ln -s /path/to/__git_info.fish ~/.config/fish/functions/__git_info.fish
   ```

3. add to call this anywhere you like, such as in `fish-right-prompt`. (same
   above)
