##Solo cooking with chef-solo##

![Chef logo](http://tickets.opscode.com/secure/projectavatar?pid=10000&avatarId=11981&size=large)

Unlike the Server driven [cookbook intro I wrote a while back](http://www.hagzag.com/blog/2013/01/20/writing-a-chef-cookbook/), I came across a need of using solo,
I must admit it's been quite while hacking @ Chef and it's come a long way ...
BTW, if you dont have a mac - don't try this ... ;) => this was tested on ![Mountin Lion](http://users.skynet.be/moonapp/images/general/MountainLion43.png)

#### Cut the bulls**t ####
If you are saying to your self I want to get my hands dirty - cut the bulls**t so just:
```bash 
git clone https://github.com/cookbase/laptop.git
cd laptop && soloist
```
Wait for magic to happen ...


## What we are going todo ? ##
Install some stuff on my laptop for this example: Sublime text 2 (version 2.0.2), Vagrant (version 1.2.2), Hombrew latest ...

Let's do some OSX settings on our mac - for example 
	1. Hide the dock [auto-hide the doc], 
	2. Finder: show hidden files by default
	3, maybe more ...

Yeah, Yeah I know there are three ton of this kind of solutions like [pivotal_workstation](https://github.com/pivotal/pivotal_workstation), [kitchenplan](https://github.com/kitchenplan/kitchenplan) - which is based on pivotal & others.
All of them where / are overwhelming in the amount of stuff they bring in, the majority of them have proprietary / comercial packages like 1password and others which I didn't want. So instead of "ripping them off" let's build our own and learn something whilst were @ it ...

	**The good news is 90%** are already out there so let's get it on ...

## Getting started (sharpen you knife .... / the tool set) ##
1. git [ of you plan on sharing ]
2. ruby - duah !? :)
3. bundler 
4. librarian-chef [ Like bundler but for chef recipes ... ]
5. we could also use *[soloist](https://github.com/mkocher/soloist)* which is a gem which represents our node as yaml instead of json - kind handy see example below of such a file

I assume you have ruby and gems install so I can continue from here ...

## Create a project folder
	
	mkdir laptop 

###	Create a git repo
```bash 
cd laptop && git init .
```
###	Create a git ignore file [ We do not want cookbooks & cookbook cache to make way into our repository ]
```bash
cat > .gitignore << EOF
cookbooks
tmp
EOF
```

## Create Gemfile with deps ...
```bash 
cat > Gemfile <<EOF
source :rubygems
gem 'chef'
gem 'soloist'
EOF
```
Let's get those gems ...
```bash 
bundle
```
Long list (see the deps librarian & libraian-chef ... by running *gem list* )

```ruby
Using chef (11.4.4) 
Installing hashie (1.2.0) 
Using thor (0.18.1) 
Using librarian (0.1.0) 
Using librarian-chef (0.0.1) 
Installing soloist (1.0.1) 
Using bundler (1.3.5) 
```

## My dmg's & Cookbook deps ... 

Sublime Text2 - link: http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2.dmg.
Vagrant - link: http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/Vagrant-1.2.2.dmg

And I will need the dmg cookbook in order to install then [ put a pin in that when we get to librarian / soloist ... ]
In order to set mac osx stuff like I mentioned I can use the [mac_os_x cookbook by opscode](http://community.opscode.com/cookbooks/mac_os_x)

Optional but recommended - get the shasum of the dmg's so the download is validated before installation for example:
```bash
shasum -a 256 ~/Downloads/Sublime\ Text\ 2.0.2.dmg 
906e71e19ae5321f80e7cf42eab8355146d8f2c3fd55be1f7fe5c62c57165add  /Users/c5191707/Downloads/Sublime Text 2.0.2.dmg
```

## Write your own *cookbook* ... [ reuse others in your cookbook]
```bash	
mkdir -p ./site-cookbooks/cookbase/{attributes,files,recipes}
*vim ./site-cookbooks/cookbase/attributes/default.rb 	*
```
Tell our recipe where to get the dmg's from, and these can be changed to fit your local artifact server / repo.
```ruby
default[:cookbase][:st_pkg_url] = "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2.dmg"
default[:cookbase][:vagrant_pkg_url] = "http://files.vagrantup.com/packages/7e400d00a3c5a0fdf2809c8b5001a035415a607b/Vagrant-1.2.2.dmg"
```
*vim ./site-cookbooks/cookbase/recipes/default.rb*
Let's use the dmg cookbook for our packadges:
```ruby
dmg_package 'Sublime Text 2' do
  source "#{node[:cookbase][:st_pkg_url]}"
  checksum "906e71e19ae5321f80e7cf42eab8355146d8f2c3fd55be1f7fe5c62c57165add"
end
link "/usr/local/bin/subl" do
  to '/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl'
end
```
And the same kind of chunk for Vagrant ...
```ruby	
dmg_package 'Vagrant' do
  source "#{node[:cookbase][:vagrant_pkg_url]}"
  checksum "1581552841e076043308f330a5b1130b455c604846116c54b5330bb17240c7ee"
  type 'pkg'
  package_id 'com.vagrant.vagrant'
end
```
And the OSX tweaks are achived by appending the following to the default.rb:
```ruby
include_recipe 'cookbase::osx_hacks'	
```
And of course creating the osx_hacks.rb file [ in thre recipes directory ]
I put the first one as an example you can see the full file in [the repository](https://github.com/cookbase/laptop) ...

```ruby
mac_os_x_userdefaults 'Finder: show hidden files by default' do
  domain 'com.apple.finder'
  key 'AppleShowAllFiles'
  value 'true'
  type 'bool'
end	
```

## Create a *Cheffile*
```bash
cat > Cheffile << EOF
cookbook 'mac_os_x'
cookbook 'dmg'	
cookbook 'homebrew'
cookbook 'ruby_build'
cookbook 'zip_app'
EOF
```

## Create *Soloist* file
```bash
cat > recipes: << EOF
  - mac_os_x
  - homebrew
  - dmg
  - zip_app
  - cookbase
EOF
```
## Alternatively a json file [ before the soloist option ... ] would look like:
```ruby
{
    "run_list": [
        "recipe[mac_os_x]",
        "recipe[dmg]",
        "recipe[homebrew]",
        "recipe[zip_app]",
        "recipe[cookbase]"
    ]
}
```
*But we don't need one in our case ...*
Just to note what happens behind the scenes 

## Let's execute soloist and see how much clutter it saves us ...
```bash
$ soloist 
Installing dmg (1.1.0)
Installing homebrew (1.3.2)
Installing mac_os_x (1.4.2)
Installing zip_app (0.2.2)
```
So, in the background soloist runs *librarian chef* and pulls down all the cookbooks [ defaults to: http://community.opscode.com/cookbooks/ ].
```bash
	Starting Chef Client, version 11.4.4
	[2013-07-16T00:21:18+03:00] INFO: *** Chef 11.4.4 ***
	[2013-07-16T00:21:19+03:00] INFO: Setting the run_list to ["mac_os_x", "homebrew", "dmg", "zip_app", "cookbase"] from JSON
	[2013-07-16T00:21:19+03:00] INFO: Run List is [recipe[mac_os_x], recipe[homebrew], recipe[dmg], recipe[zip_app], recipe[cookbase]]
	[2013-07-16T00:21:19+03:00] INFO: Run List expands to [mac_os_x, homebrew, dmg, zip_app, cookbase]
	[2013-07-16T00:21:19+03:00] INFO: Starting Chef Run for TLVM60232271A
	[2013-07-16T00:21:19+03:00] INFO: Running start handlers
	[2013-07-16T00:21:19+03:00] INFO: Start handlers complete.
	Compiling Cookbooks...
	Converging 12 resources
	Recipe: homebrew::default
	  * remote_file[/var/chef/cache/homebrew_go] action create[2013-07-16T00:21:19+03:00] INFO: Processing remote_file[/var/chef/cache/homebrew_go] action create (homebrew::default line 3)
	 (up to date)
	  * execute[/var/chef/cache/homebrew_go] action run[2013-07-16T00:21:20+03:00] INFO: Processing execute[/var/chef/cache/homebrew_go] action run (homebrew::default line 8)
	 (skipped due to not_if)
	  * package[git] action install[2013-07-16T00:21:20+03:00] INFO: Processing package[git] action install (homebrew::default line 12)
	 (skipped due to not_if)
	  * execute[update homebrew from github] action run[2013-07-16T00:21:20+03:00] INFO: Processing execute[update homebrew from github] action run (homebrew::default line 16)
	[2013-07-16T00:21:20+03:00] INFO: execute[update homebrew from github] ran successfully

	    - execute /usr/local/bin/brew update || true

	Recipe: cookbase::default
	  * dmg_package[Sublime Text 2] action install[2013-07-16T00:21:20+03:00] INFO: Processing dmg_package[Sublime Text 2] action install (cookbase::default line 3)
	[2013-07-16T00:21:20+03:00] INFO: Already installed; to upgrade, remove "/Applications/Sublime Text 2.app"
	 (up to date)
	  * link[/usr/local/bin/subl] action create[2013-07-16T00:21:20+03:00] INFO: Processing link[/usr/local/bin/subl] action create (cookbase::default line 7)
	 (up to date)
	  * dmg_package[Vagrant] action install[2013-07-16T00:21:20+03:00] INFO: Processing dmg_package[Vagrant] action install (cookbase::default line 13)
	com.vagrant.vagrant
	[2013-07-16T00:21:20+03:00] INFO: Already installed; to upgrade, try "sudo pkgutil --forget com.vagrant.vagrant"
	 (up to date)
	Recipe: cookbase::osx_hacks
	  * mac_os_x_userdefaults[Finder: show hidden files by default] action write[2013-07-16T00:21:20+03:00] INFO: Processing mac_os_x_userdefaults[Finder: show hidden files by default] action write (cookbase::osx_hacks line 3)


	Recipe: <Dynamically Defined Resource>
	  * execute[defaults write com.apple.finder 'AppleShowAllFiles' -bool 'true'] action run[2013-07-16T00:21:20+03:00] INFO: Processing execute[defaults write com.apple.finder 'AppleShowAllFiles' -bool 'true'] action run (/Users/c5191707/Projects/cookbase/laptop2/cookbooks/mac_os_x/providers/userdefaults.rb line 70)
	[2013-07-16T00:21:20+03:00] INFO: execute[defaults write com.apple.finder 'AppleShowAllFiles' -bool 'true'] ran successfully

	    - execute defaults write com.apple.finder 'AppleShowAllFiles' -bool 'true'

	Recipe: cookbase::osx_hacks
	  * mac_os_x_userdefaults[Finder: show all filename extensions] action write[2013-07-16T00:21:20+03:00] INFO: Processing mac_os_x_userdefaults[Finder: show all filename extensions] action write (cookbase::osx_hacks line 10)


	Recipe: <Dynamically Defined Resource>
	  * execute[defaults write NSGlobalDomain 'AppleShowAllExtensions' -bool 'true'] action run[2013-07-16T00:21:20+03:00] INFO: Processing execute[defaults write NSGlobalDomain 'AppleShowAllExtensions' -bool 'true'] action run (/Users/c5191707/Projects/cookbase/laptop2/cookbooks/mac_os_x/providers/userdefaults.rb line 70)
	[2013-07-16T00:21:20+03:00] INFO: execute[defaults write NSGlobalDomain 'AppleShowAllExtensions' -bool 'true'] ran successfully

	    - execute defaults write NSGlobalDomain 'AppleShowAllExtensions' -bool 'true'

	Recipe: cookbase::osx_hacks
	  * mac_os_x_userdefaults[Remove the auto-hiding Dock delay] action write[2013-07-16T00:21:20+03:00] INFO: Processing mac_os_x_userdefaults[Remove the auto-hiding Dock delay] action write (cookbase::osx_hacks line 17)


	Recipe: <Dynamically Defined Resource>
	  * execute[defaults write com.apple.dock 'autohide-delay' -float '0'] action run[2013-07-16T00:21:20+03:00] INFO: Processing execute[defaults write com.apple.dock 'autohide-delay' -float '0'] action run (/Users/c5191707/Projects/cookbase/laptop2/cookbooks/mac_os_x/providers/userdefaults.rb line 70)
	[2013-07-16T00:21:20+03:00] INFO: execute[defaults write com.apple.dock 'autohide-delay' -float '0'] ran successfully

	    - execute defaults write com.apple.dock 'autohide-delay' -float '0'

	Recipe: cookbase::osx_hacks
	  * mac_os_x_userdefaults[Remove the animation when hiding/showing the Dock] action write[2013-07-16T00:21:20+03:00] INFO: Processing mac_os_x_userdefaults[Remove the animation when hiding/showing the Dock] action write (cookbase::osx_hacks line 24)


	Recipe: <Dynamically Defined Resource>
	  * execute[defaults write com.apple.dock 'autohide-time-modifier' -float '0'] action run[2013-07-16T00:21:21+03:00] INFO: Processing execute[defaults write com.apple.dock 'autohide-time-modifier' -float '0'] action run (/Users/c5191707/Projects/cookbase/laptop2/cookbooks/mac_os_x/providers/userdefaults.rb line 70)
	[2013-07-16T00:21:21+03:00] INFO: execute[defaults write com.apple.dock 'autohide-time-modifier' -float '0'] ran successfully

	    - execute defaults write com.apple.dock 'autohide-time-modifier' -float '0'

	Recipe: cookbase::osx_hacks
	  * mac_os_x_userdefaults[Automatically hide and show the Dock] action write[2013-07-16T00:21:21+03:00] INFO: Processing mac_os_x_userdefaults[Automatically hide and show the Dock] action write (cookbase::osx_hacks line 31)


	Recipe: <Dynamically Defined Resource>
	  * execute[defaults write com.apple.dock 'autohide' -bool 'true'] action run[2013-07-16T00:21:21+03:00] INFO: Processing execute[defaults write com.apple.dock 'autohide' -bool 'true'] action run (/Users/c5191707/Projects/cookbase/laptop2/cookbooks/mac_os_x/providers/userdefaults.rb line 70)
	[2013-07-16T00:21:21+03:00] INFO: execute[defaults write com.apple.dock 'autohide' -bool 'true'] ran successfully

	    - execute defaults write com.apple.dock 'autohide' -bool 'true'

	[2013-07-16T00:21:21+03:00] INFO: Chef Run complete in 1.473199 seconds
	[2013-07-16T00:21:21+03:00] INFO: Running report handlers
	[2013-07-16T00:21:21+03:00] INFO: Report handlers complete
	Chef Client finished, 11 resources updated
```

Great bottom line **	Chef Client finished, 11 resources updated** ...

References:

1. [Sololist repository see the README.md](https://github.com/mkocher/soloist)
2. Another awesome tool out there is: [solowizard](http://www.solowizard.com/) - mix 'n' match, generate a script which uses chef-solo to bootstrap your laptop.
