# Important info, please read

## Everyone here is another developer

...there's no support team. When you create an Issue, it will be seen by the other users of SVGKit. If someone answers, it's because they're a fellow user and they're trying to help.

Some of them are kind enough to fix things for other developers - but please note they're doing it out of generosity!

## A short (3 sentence) Issue is often the best

The Issues that get fastest response / resolved best are often the shortest - but not TOO short.

Adam <a href="http://t-machine.org/index.php/2013/12/22/reporting-issues-in-open-source-software/">wrote an ultra short guide: How to write a good Issue</a> - it's worth a quick read!

## Pull Requests

We love Pull Requests. Most get accepted within hours.

But there's a couple of hard and fast rules, to protect all of us:

1. A Pull Request MUST be a small, self-contained feature or fix, or a couple of fixes at most. It could stretch over many files, but usually it will be 2-5 files at most.
1. ...because: a Maintainer will *manually check every line of code* in the Pull Request, and make sure it doesn't break anything else
1. If your code breaks other stuff, we'll tell you why and help you to fix it
1. EVERY PULL REQUEST should be first tested using the "Demo-iOS" app (or "Demo-OSX" app) to make sure it works with all our current SVG files
1. If you're fixing a bug, PLEASE CREATE A SIMPLE SVG FILE THAT DEMONSTRATES THE BUG, and then a Maintainer can add it to the Demo app, and use it to "prove" that your fix works. (or you can add it yourself directly, as part of your commit)
1. When you send a Pull Request, you warrant that it's your own code, or that you have permission to donate it to the project (this should be obvious! It's open-source!)

# Coding Style

We have very few rules for coding style. But there are a couple of things that affect other programmers:

1. Don't reformat existing code unless it's VERY badly formatted - it makes it TEN TIMES HARDER for us to check your changes (it will mess up all the diff's)
