Copied, for safe keeping, from [https://musteresel.github.io/posts/2018/01/git-worktree-for-deploying.html](https://musteresel.github.io/posts/2018/01/git-worktree-for-deploying.html)

# Using git worktree for deploying to GitHub Pages

2018-01-27

GitHub Pages can be [configured](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/) to publish from a `gh-pages` branch, or - in case of a "user page" - it uses the `master` branch for publishing.

I generate the files for publishing with my own blog system, whose sources are in a `sources-master` branch. The generated files are written into a subfolder `build/` (which is in `.gitignore` so that generated files won't end up on the sources branch). In order to add any changes in `build/` to the (in my case) `master` branch there are [different approaches](https://gist.github.com/cobyism/4730490), but I think I found a better one:

## git worktrees

git [supports](https://git-scm.com/docs/git-worktree) multiple "worktrees". A worktree is the part of your repository (except for bare repositories) you normally interact with when you change and add files. Normally one works with the single "main" worktree. Adding a new worktree is extremely easy though and allows one to keep the main worktree in any (however dirty) state it's currently in:

    git worktree add ./build master
    cd ./build
    touch some-new-file
    git add some-new-file
    git commit -m "added some new file"


This checks out the branch `master` into the subdirectory `./build` (can also be an absolute path, of course). Then it changes into said directory, creates and adds a new file to the repository and commits this change. This commit now goes directly to the `master` branch, regardless of which branch or commit the main worktree currently is on.

The worktree (or better, the information about it in the `.git` repository) is eventually deleted when the containing directory (`./build` here) is removed.

For deploying, this means I can:

1.  Check if `./build` is a worktree using `git worktree list`
    *   if it is, make sure it's up to date:

        <div class="sourceCode">

            cd ./build
            git checkout master
            git pull
            cd ..

        </div>

    *   else, create the new worktree: `git worktree add ./build master`

2.  Build the files to publish in `./build`
3.  Change into the the directory `./build`
4.  Add all files `git add .`
5.  Commit (and optionally push directly)

For step 4 it's important to have a `.gitignore` file on the `master` branch so that any files which should not be published (for example caches or auxilary files from the build) will be ignored.

## Advantages

*   There are no generated files on the same branch (read visible during development / writing) as the source files. (The `git subtree` method suffers from this issue.)

*   It's a single (local) repository that I'm working with. No need to `clone`, no space wasted, no duplicate (local) repository configurations.
