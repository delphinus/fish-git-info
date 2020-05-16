function __git_info

  # simulates pseudo-`dict` feature in fish
  # https://stackoverflow.com/a/60191660
  function set_field --argument-names key value
    set -g '__git_fish__'$key $value
  end

  function get_field --argument-names key
    eval echo \$'__git_fish__'$key $value
  end

  function __action
    set -l git_dir $argv[1]

    for dir in "$git_dir/rebase-apply" "$git_dir/rebase" "$git_dir/../.dotest"
      if test -d $dir
        set -q FISH_GIT_INFO_ACTION_REBASE; or set -g FISH_GIT_INFO_ACTION_REBASE rebase
        set -q FISH_GIT_INFO_ACTION_APPLY; or set -g FISH_GIT_INFO_ACTION_APPLY apply
        if test -f "$dir/rebasing"
          echo -n $FISH_GIT_INFO_ACTION_REBASE
        else if test -f "$dir/applying"
          echo -n $FISH_GIT_INFO_ACTION_APPLY
        else
          echo -n $FISH_GIT_INFO_ACTION_REBASE/$FISH_GIT_INFO_ACTION_APPLY
        end
        return 0
      end
    end

    for file in "$git_dir/rebase-merge/interactive" "$git_dir/.dotest-merge/interactive"
      if test -f $file
        set -q FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE; or set -g FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE rebase-interactive
        echo -n $FISH_GIT_INFO_ACTION_REBASE_INTERACTIVE
        return 0
      end
    end

    for dir in "$git_dir/rebase-merge" "$git_dir/.dotest-merge"
      if test -d $dir
        set -q FISH_GIT_INFO_ACTION_REBASE_MERGE; or set -g FISH_GIT_INFO_ACTION_REBASE_MERGE rebase-merge
        echo -n $FISH_GIT_INFO_ACTION_REBASE_MERGE
        return 0
      end
    end

    if test -f "$dir/MERGE_HEAD"
      set -q FISH_GIT_INFO_ACTION_MERGE; or set -g FISH_GIT_INFO_ACTION_MERGE merge
      echo -n $FISH_GIT_INFO_ACTION_MERGE
      return 0
    end

    if test -f "$dir/CHERRY_PICK_HEAD"
      if test -d "$dir/sequencer"
        set -q FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE; or set -g FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE cherry-pick
        echo -n $FISH_GIT_INFO_ACTION_CHERRY_PICK_SEQUENCE
      else
        set -q FISH_GIT_INFO_ACTION_CHERRY_PICK; or set -g FISH_GIT_INFO_ACTION_CHERRY_PICK cherry-pick
        echo -n $FISH_GIT_INFO_ACTION_CHERRY_PICK
      end
      return 0
    end

    if test -f "$dir/REVERT_HEAD"
      if test -d "$dir/sequencer"
        set -q FISH_GIT_INFO_ACTION_REVERT_SEQUENCE; or set -g FISH_GIT_INFO_ACTION_REVERT_SEQUENCE revert
        echo -n $FISH_GIT_INFO_ACTION_REVERT_SEQUENCE
      else
        set -q FISH_GIT_INFO_ACTION_REVERT; or set -g FISH_GIT_INFO_ACTION_REVERT revert
        echo -n $FISH_GIT_INFO_ACTION_REVERT
      end
      return 0
    end

    if test -f "$dir/BISECT_LOG"
      set -q FISH_GIT_INFO_ACTION_BISECT; or set -g FISH_GIT_INFO_ACTION_BISECT bisect
      echo -n $FISH_GIT_INFO_ACTION_BISECT
      return 0
    end

    functions -e __action
  end

  function _git_stash_info
    set stashed (command git stash list 2> /dev/null | wc -l | awk '{print $1}')
    if test -n "$stashed"
      echo -n (set_color blue)"✭ $stashed"(set_color normal)
    end

    functions -e _git_stash_info
  end

  function _git_branch_info
    set ahead_and_behind (command git rev-list --count --left-right 'HEAD...@{upstream}' 2> /dev/null)
    if test -n "$ahead_and_behind"
      set ahead (echo -n $ahead_and_behind | cut -f1)
      set behind (echo -n $ahead_and_behind | cut -f2)
      test $ahead -ne 0 ;and echo -n (set_color brmagenta)" ⬆ $ahead"(set_color normal)
      test $behind -ne 0 ;and echo -n (set_color brmagenta)" ⬇ $behind"(set_color normal)
    end

    functions -e _git_branch_info
  end

  function _git_status_info
    set git_status (command git status --porcelain)
    if test -n "$git_status"
      set added 0
      set deleted 0
      set modified 0
      set renamed 0
      set unmerged 0
      set untracked 0
      for line in $git_status
        string match -r '^([ACDMT][ MT]|[ACMT]D) *' $line > /dev/null ;and set added (math $added + 1)
        string match -r '^[ ACMRT]D *]' $line > /dev/null ;and set deleted (math $deleted + 1)
        string match -r '^.[MT] *' $line > /dev/null ;and set modified (math $modified + 1)
        string match -r '^R. *' $line > /dev/null ;and set renamed (math $renamed + 1)
        string match -r '^(AA|DD|U.|.U) *' $line > /dev/null ;and set unmerged (math $unmerged + 1)
        string match -r '^\?\? *' $line > /dev/null ;and set untracked (math $untracked + 1)
      end

      test $added -ne 0 ;and echo -n (set_color green)"✚ $added"(set_color normal)
      test $deleted -ne 0 ;and echo -n (set_color red)"✖ $deleted"(set_color normal)
      test $modified -ne 0 ;and echo -n (set_color blue)"✱ $modified"(set_color normal)
      test $renamed -ne 0 ;and echo -n (set_color magenta)"➜ $renamed"(set_color normal)
      test $unmerged -ne 0 ;and echo -n (set_color blue)"═ $unmerged"(set_color normal)
      test $untracked -ne 0 ;and echo -n (set_color white)"◼ $untracked"(set_color normal)
    end

    functions -e _git_status_info
  end

  function print_results
    for key in (string match -ar %. "$FISH_GIT_INFO")
      set i (string replace % '' $key)
      set -a results (get_field $i)(set_color normal)
    end
    set format (string replace -ar %. %s "$FISH_GIT_INFO")
    printf "$format" $results
  end

  if test -n "$FISH_GIT_INFO"
    set git_dir (git rev-parse --git-dir 2> /dev/null)
    if test -n "$git_dir"

      # branch -- %b
      if test -n "$FISH_GIT_INFO_BRANCH"
        set branch (command git symbolic-ref HEAD 2> /dev/null | perl -pe 's,^refs/heads/,,')
        if test -n "$branch"
          set_field b (printf "$FISH_GIT_INFO_BRANCH" "$branch")
        end
      end

      # position -- %p
      if test -n "$FISH_GIT_INFO_POSITION"
        set position (command git describe --contains --all HEAD 2> /dev/null)
        if test -n "$position"
          if test -n "$branch"; and test "$branch" != "$position"
            set_field p (printf "$FISH_GIT_INFO_POSITION" "$position")
          else if test -z "$branch"
            set_field p (printf "$FISH_GIT_INFO_POSITION" "$position")
          end
        end
      end

      # commit -- %c
      if test -n "$FISH_GIT_INFO_COMMIT"
        set commit (command git rev-parse HEAD 2> /dev/null | cut -c-7)
        if test -n "$commit"
          set_field c (printf "$FISH_GIT_INFO_COMMIT" "$commit")
        end
      end

      # action -- %s
      if test -n $FISH_GIT_INFO_ACTION
        set -l action (__action "$git_dir")
        if test -n "$action"
          set_field s (printf "$FISH_GIT_INFO_ACTION" "$action")
        end
      end

      print_results

      _git_stash_info
      _git_status_info
    end
  end
end
