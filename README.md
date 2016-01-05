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
