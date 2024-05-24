GNU Emacs 23.1.1 (i386-mingw-nt6.1.7601)
Installed in Program Files (64-bit)


## Javascript ##

You have to compile the Javascript library for it to work at all via

	M-x byte-compile file ~/.emacs.d/lib/js2.el

If that fails, follow the instructions at
<http://code.google.com/p/js2-mode/issues/detail?id=68>.


## Markdown ##

Installed in ~/.emacs.d/lib/markdown.


## Org-mode ##

Install version 7.8.11 from <http://orgmode.org/org-7.8.11.zip>.

On windows, you need to install org-mode as an administrator.  To do
this:

- Run cmd.exe as an administrator.
- Run an elevated bash shell from the command window.
- Run <code>make install</code> in the elevated bash shell.
