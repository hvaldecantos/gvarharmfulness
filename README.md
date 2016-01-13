# Global Variable Harmfulness
The name gvar stands for Global Variable. This project is about measuring global
variables harmfulness related to bug fixes found in a software system written in
C. We make use of [gvar project](https://github.com/hvaldecantos/gvar) to gather
the required data.

# Clonning gvarharmfulness project

There are git submodules inside this project, therefore you need to clone the
other projects on which gvarharmfulness depends on.

To clone and download all projects in once step:

```
$ git clone --recursive git@gitlab.com:hvaldecantos/gvarharmfulness.git
```

To clone gvarharmfulness project and download git submodules in separate steps:
```
$ git clone git@gitlab.com:hvaldecantos/gvarharmfulness.git
$ git submodule init
$ git submodule update
```

# Running gvarharmfulness project

## Install Ruby Version Manager (RVM).

For security you need to install the RVM maitainer's public key, then download RVM using curl, run an rvm script, and add a instruction in .bashrc (for ubuntu) to load RVM in your session. You can read https://rvm.io/rvm/install if you need.

```
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
$ \curl -L https://get.rvm.io | bash -s stable
$ source /home/<user>/.rvm/scripts/rvm
```
Add at the end of .bashrc file the following directives:
```
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
```

Once RVM is installed, open a new terminal and go to the project's directory. RVM should warn you to install the required ruby version for the project, just follow the instructions.

## Install required dependencies in your system:

* Git: http://www.git-scm.com/
* Mongodb: https://www.mongodb.org/
* Exuberant ctags: http://ctags.sourceforge.net/

## Configure your project
Configure what projects you want to analyze. A `config/projects_to_analyze.config` file looks like this:

```
gtk+ gtk
sed sed
wget src
cpio src
gzip .
```

Each row indicates the project's directory name and the directory to analyze for each project. Look at `projects/` to see available projects to analyze.

You also need to add the environment file `config/env.yml` to set the prefix for mongo databases for each analized project. The file should look like this:

```
database:
  PREFIX_DB_NAME: i
```

The prefix db name will result in mongo database names like `i_gtk+`, `i_sed+`, etc.

## Install ruby dependencies

Ruby gem dependencies are written in `Gemfile`, you can install them using bundler.

```
$ cd gvarharmfulness
$ bundle install
```

If bundler is not installed just do `$ gem bundler install` and them install

## Run the project

```
$ cd gvarharmfulness
$ ruby data_collector.rb
```

The data collector will read configuration, gather data from project, store data in mongo dbs, and write results for each project in `results/` directory.
