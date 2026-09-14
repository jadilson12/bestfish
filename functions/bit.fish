function bit --description 'Shorthand front end for the git commands used every day'
    # Originally by helmuthdu (Archlinux Ultimate Install).
    #
    # fish's `switch` is case sensitive, so the `C`/`c` and `P`/`p` pairs stay
    # as distinct as they were under bash's `case`.
    switch "$argv[1]"
        case --init
            set -l name (git config --global user.name)
            set -l email (git config --global user.email)
            set -l user (git config --global github.user)
            set -l editor (git config --global core.editor)

            test -n "$name"; or read -P "Name: " name
            test -n "$email"; or read -P "Email: " email
            test -n "$user"; or read -P "Username: " user
            test -n "$editor"; or read -P "Editor: " editor

            git config --global user.name "$name"
            git config --global user.email "$email"
            git config --global github.user "$user"
            git config --global core.editor "$editor"
            git config --global color.ui true
            git config --global color.status auto
            git config --global color.branch auto
            git config --global color.diff auto
            git config --global diff.color true
            git config --global core.filemode true
            git config --global push.default matching
            git config --global format.signoff true
            git config --global alias.reset 'reset --soft HEAD^'
            git config --global alias.graph 'log --graph --oneline --decorate'
            git config --global alias.compare 'difftool --dir-diff HEAD^ HEAD'
            if type -q meld
                git config --global diff.guitool meld
                git config --global merge.tool meld
            else if type -q kdiff3
                git config --global diff.guitool kdiff3
                git config --global merge.tool kdiff3
            end
            git config --global --list

        case a add
            if test "$argv[2]" = --all
                git add -A
            else
                git add $argv[2..]
            end

        case b branch
            switch "$argv[2]"
                case feature
                    if not _bit_has_branch unstable
                        echo "creating unstable branch..."
                        git branch unstable
                        git push origin unstable
                    end
                    git checkout -b feature --track origin/unstable
                case hotfix
                    git checkout -b hotfix master
                case master
                    git checkout master
                case ''
                    _bit_usage
                case '*'
                    if not _bit_has_branch $argv[2]
                        echo "creating $argv[2] branch..."
                        git branch $argv[2]
                        git push origin $argv[2]
                    end
                    git checkout $argv[2]
            end

        case c commit
            if test "$argv[2]" = --undo
                git reset --soft HEAD^
            else
                git commit -am "$argv[2]"
            end

        case C cherry-pick
            # $argv[2] commit, $argv[3] remote url, $argv[4] branch
            git checkout -b patch master
            git pull $argv[3] $argv[4]
            git checkout master
            git cherry-pick $argv[2]
            git log --graph --oneline --decorate -5
            git branch -D patch

        case d delete
            if _bit_has_branch $argv[2]
                git branch -D $argv[2]
                git push origin --delete $argv[2]
            else
                echo "No branch found."
            end

        case l log
            git log --graph --oneline --decorate

        case m merge
            switch "$argv[2]"
                case --fix
                    git mergetool
                case feature
                    if _bit_has_branch feature
                        git checkout unstable
                        git difftool -g -d unstable..feature
                        git merge --no-ff feature
                        git branch -d feature
                        git commit -am "$argv[3]"
                    else
                        echo "No feature branch found."
                    end
                case hotfix
                    if _bit_has_branch hotfix
                        # merge into the upstream branch
                        git checkout -b unstable origin
                        git merge --no-ff hotfix
                        git commit -am "hotfix: v$argv[3]"
                        # then into master
                        git checkout -b master origin
                        git merge hotfix
                        git commit -am "Hotfix: v$argv[3]"
                        git branch -d hotfix
                        git tag -a $argv[3] -m "Release: v$argv[3]"
                        git push --tags
                    else
                        echo "No hotfix branch found."
                    end
                case '*'
                    if _bit_has_branch $argv[2]
                        git checkout -b master origin
                        git difftool -g -d master..$argv[2]
                        git merge --no-ff $argv[2]
                        git branch -d $argv[2]
                        git commit -am "$argv[3]"
                    else
                        echo "No $argv[2] branch found."
                    end
            end

        case p push
            git push origin $argv[2]

        case P pull
            if test "$argv[2]" = --force
                git fetch --all
                git reset --hard origin/master
            else
                git pull origin $argv[2]
            end

        case r release
            git checkout origin/master
            git merge --no-ff origin/unstable
            git branch -d unstable
            git tag -a $argv[2] -m "Release: v$argv[2]"
            git push --tags

        case '*'
            _bit_usage
    end
end
