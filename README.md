# SHELI

SHell Extensible Library (sheli) offers you a little help in building your scripts.
In particular it takes care of some repetitive tasks, such as parameters management.

It is not fully tested yet, so be careful \[:

It adds some automatism, such as the main function, signal management, and some more!
It also comes with a custom version of argparse!

This library is experimental and actually uses dash as interpreter.
Wherever possible, POSIX standards are used, BUT sometimes they are not (a.k.a. local vars et similia).

In this repo a TL;DR will eventually be included with the methods intended to be used.

## Getting Started

### Prerequisites

Please, read all this readme (yes, including notes).

You should have installed DASH in order to let sheli work fine, **but** if you don't want to install dash, you can easily change the shebang in each lib with the following command:
```
find . -type f -name '*.sh' -exec sed -i -e 's|#!/bin/.*sh|#!/bin/bash|' "{}" \;
```
BASH should be fine although it is not tested.

### Installing

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

First of all, clone the repo:

```
git clone https://github.com/ingroxd/sheli.git
```

This is actually all you need to do to install it.

I usually put it in ~/Documents and create a symbolic link in /opt just to have a standard:

```
mkdir -p ~/Documents/sheli
git clone https://github.com/ingroxd/sheli.git ~/Documents/sheli
ln -s /home/user/Documents/sheli /opt/sheli
```

This is personal and you can/should use the path you prefer the most.

## Running the tests

In order to use it, just put in your script the following:

```
readonly SHELI_DIR='/path/to/sheli'
. "${SHELI_DIR}/sheli.sh"
```

Please, note that $SHELI_DIR is mandatory and it will cause an error if not declared.

Try copy-pasting this short script:
```
#!/bin/bash

readonly SHELI_DIR='/opt/sheli'
. "${SHELI_DIR}/sheli.sh"

sheli__main "${@}"
```

If everything works as should, you will have an error for NOT having a main function

## Deployment

In your script, you have to declare some variables and some functions.
In the repo there is an example script with additional memos.

Long story short, all you have to declare are the options your script needs (through argparse) and a main function.

The function main() is mandatory and an error will be thrown if not declared.

Optionally, you can declare function as ctrl_c, cleanup, die, etc.

## Contributing

If you think something could be more flexible/robust/modular/fast/something, **please**, you are welcome to suggest/edit/fork/whatever in order to help this project grow!

I will be happy to explain why I made some strange choices in coding, **but** I will be happier to hear suggestion and some healthy criticism to improve code and myself.

One thing I will probably insist about is to have little dependencies as possible and/or wide-spreaded ones only (E.G. printf, tee, date, etc.)

## Authors

* **Gregorio Casa** - *Initial work* - [ingroxd](https://github.com/ingroxd)

See also the list of [contributors](https://github.com/ingroxd/sheli/contributors) who participated in this project.

## License

This project is still without any license yet, but I think I will opt-in for a GNU-GPLv3 License

## Acknowledgments

* This project was born because of those repetitive tasks I always have to write for every script.
* Please, bear in mind that the aim of this project is NOT efficiency (in terms of speed).

