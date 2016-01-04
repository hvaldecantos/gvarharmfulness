# Global Variable Harmfulness
The name gvar stands for Global Variable. This project is about measuring global
variables harmfulness related to bug fixes found in a software system written in
C. We make use of [gvar project](https://github.com/hvaldecantos/gvar) to gather
the required data.

# Clonning gvarharmfulness project

There are git submodules inside this project, therefore you need to clone the
other projects on which gvarharmfulness depends on.

To download all projects at once:

```
$ git clone --recursive git@gitlab.com:hvaldecantos/gvarharmfulness.git
```

To clone gvarharmfulness and download gvar project:
```
$ git clone git@gitlab.com:hvaldecantos/gvarharmfulness.git
$ cd gvarharmfulness/gvar
$ git submodule init
$ git submodule update
```

For the other projects just follow a similar procedure.
