---
layout: post
title:  "Spacemacs for ns-3 development"
date:   2017-07-29
---

I've been using [Spacemacs][spacemacs] as my editor of choice for a while now,
and one of my main tasks at work has been the development of an [ns-3][ns-3]
module for simulation of IoT technologies.

Since the two pieces of software don't integrate well out of the box, here are
some lines on how it's possible to leverage the features of Spacemacs to
accelerate ns-3 development.

## Autocompletion and syntax checking ##

[ycmd][ycmd] is a code-completion and comprehension server that can be leveraged
by the Flycheck and Company Emacs packages to provide syntax checking and
auto-completion features. This setup will make development easier by
highlighting syntactical errors right from the buffer and by providing smart
completion for all member methods we can call on an object.

### Installing ycmd

ycmd is a server, running in the background, to which Emacs can ask completion
information. Building this software is pretty straightforward:

1. Clone the repo:
```bash
git clone https://github.com/Valloric/ycmd.git
```
2. Update the repo's submodules:
```bash
cd ycmd
git submodule update --init --recursive
```
3. Build it by enabling the clang completion engine:
```bash
./build.py --clang-completer
```
4. Move it to the location you prefer:
```bash
cd ..
mv -r ycmd ~/Applications/
```

### Spacemacs configuration

In order to get these components working together, it's necessary to install the
`ycmd`, `syntax-checking` and `auto-completion` Spacemacs layers. Furthermore,
we need to tell emacs where ycmd is, and to use it. In order to do this, it's
enough to add the following lines to the `user-config` section in your dotfile
(adapt the path based on where you moved the ycmd folder):

```elisp
(setq ycmd-server-command
      (list "python"
            (file-truename
             "~/Applications/ycmd/ycmd")))
(setq ycmd-force-semantic-completion t)
```

### The compilation database ##

Now that ycmd is set up to work inside emacs, we need to make sure it can
understand how our project is compiled. Since ns-3's build method leverages the
waf tool and places the compilation results in a separate folder, ycmd won't
work out of the box. The engine will look for a compilation database, usually
called `compile_commands.json`, in all directories above the current project.
ns-3 already creates this file, however it's placed inside the `build` folder,
where ycmd won't be able to find it. In order to let ycmd see it, it's enough to
symlink to it from the ns-3 root folder (where waf is). Assuming you are in that
directory, the command to do so is:

```bash
ln -s build/compile_commands.json compile_commands.json
```

## Apply style corrections on file save ##

ns-3 includes a script to check and apply styling according to their guidelines.
It's possible to set Spacemacs up so that it executes this script upon file
saves, to make sure that we are always adhering to the ns-3 coding style. To do
this, first we define a function that will apply the formatting script to the
current buffer (substitute the path to ns-3-dev based on your configuration):

```elisp
(defun ns-3-format ()
  "Format current buffer according to ns-3 standards"
  (interactive)
  (set 'scriptpath "/path/to/ns-3-dev/utils/check-style.py")
  (shell-command
   (concat scriptpath " -i -f " (buffer-file-name))
   ) ; -i for in-place updating, -f specifies file name
  (revert-buffer nil t) ; Update the buffer from file
  )
```

Next, we simply need to execute the function upon save. Since we don't want to
apply it to every C++ file, we will use project specific configurations. Edit
your ns-3-dev folder's `.dir-locals.el` file to look like the following:

```elisp
((nil. ())
 (c++-mode (eval add-hook 'after-save-hook #'ns-3-format nil t)))
```

This will make sure that the `ns-3-format` function is only called on C++ files
inside the ns-3 project.

## Default compilation and testing commands ##

You can also define project compilation and testing commands in your directory
local variables, so that Spacemacs will pre-fill them once you call
`projectile-compile-project` and `projectile-test-project`. You can do so by
customizing a couple variables in the `.dir-locals.el` file:

```elisp
((nil . ((projectile-project-compilation-cmd . "cd ../.. && ./waf build")
          (projectile-project-test-cmd . "cd ../.. && ./test.py -s lorawan") )))
```

[spacemacs]: http://spacemacs.org/
[ns-3]: http://www.nsnam.org/
[ycmd]: https://github.com/Valloric/ycmd
