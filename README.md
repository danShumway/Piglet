# Piglet

A Lua driven AI that plays classic gameboy color games using experimentation.  In active development.



### Licenses and Forking
==========================


#### Code
All of the code in this repo is meant to be distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.  It is unlikely, but possible, that some code or information meant to be kept private could be accidentally uploaded to this repo.  


To be sure of the license, double check source files to see if they have the following header.

```lua
--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--
```

The license included at the top of a file always trumps any other licenses that you see in this repo, but if you see something without a license, it's pretty safe to assume I mean it to be licensed under the GNU affero.

#### Images and other Stuff

Images, trademark, and other content-based resources seen in this repo, such as the Piglet name, logo, animations, etc.. are the private property of Daniel Shumway and Latinforimagination.

#### Can I fork it?

Absolutely, provided you follow a couple of quick instructions:

* **Follow all the rules of the license with your code:** Remember that GNU affero requires that forks license their code under the same license, and make their code available for other people to see, even if the code is running ona server.  If you plan on forking the code and setting up your own Twitch.tv stream, aweseome.  Keep your code available though.
* **Respect trademark:** Don't reuse graphics or logos that you find online.  While Piglet's code is Open Source, and while other people taking that code and doing things with it is fantastic and amazing, copying art and art styles or text is not so fantastic.  A good question to ask yourself is, "could someone mistake this for the original 'Piglet', or would they believe that this is an official branch off of the original 'Piglet' and therefore affiliated with the original creators?"
* **Attribution is apreciated:** Be honest about where you got the code - Piglet's being made in my spare time, and it's a ton of work. Keep in mind that Piglet might be responsible for me getting a job out of college.  Or drawing attention to an indie studio I launch, or just future projects in general.  If you like Piglet, and you're excited enough to take the code and run with it, just keep that in mind.
* **I'd love to see what you're doing:** While it's not by any means a requirement, if you make something cool with Piglet's code, please please show me.  I'd love to see it!

The most important thing to do when forking Piglet is to respect the copyrights and trademarks, and, to the best of your ability, to make a conscious effort not to do something jerky with it.  If you think you can handle that, by all means go crazy.  I can not begin to say how awesome forking is - so do it and make some cool crazy stuff!

Speaking of which...

###Installation and Running
=====================================================

- Install [Visual Boy Advance](https://code.google.com/p/vba-rerecording/)
    - I use an older version of Visual Boy Advance that was built with a Lua console.  From their website: "The primary function of this branch is to expand features related to the creation of Tool-assisted movies."  The great thing about using this is that all of the Lua stuff is very self-contained, so you don't even need to install Lua on your actual computer, much less do any configuration.

- Get some ROMs.
	- You're on your own mate.

- Launch
	- Under Tools->Scripting->New Lua Script window, you can launch a new console window.  Navigate to index.lua inside Piglet's base directory, then hit run.
	- Piglet will savestate as soon as she starts and if she gets bored, she'll jump back to that point.