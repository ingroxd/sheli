# SHELI

SHell Extensible Library (sheli) helps you build your scripts.
In particular it takes care of those repetitive tasks, such as parameters management and variables settings.

It adds some automatisms, such as the main function, signals management (traps), and some more things.
It also comes with a custom version of argparse.

SHELI IS SCRUMPADOOCHOUS!\*

Wherever possible, POSIX standards are used, BUT sometimes they are not (a.k.a. local vars et similia).

In this repo a TL;DR will eventually be included with the methods intended to be used.

## Getting Started

### Prerequisites

Please, read all this readme (yes, including notes, you lazy chap!).

You should have installed BASH in order to let sheli work fine, **but** if you don't want to install bash, you can easily change the shebang in each lib with the following command:
```shell
find . -type f -name '*.sh' -exec sed -i -e 's|#!/bin/.*sh|#!/bin/dash|' "{}" \;
```
*Theoretically*, you can leave shebangs as they are if you are using something that isn't BASH as interpreter for your script.

(DASH is tested and should be fine, although it is **not** fully tested.)

### Installing

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

First of all, clone the repo:

```shell
git clone https://github.com/ingroxd/sheli.git
```

This is actually all you need to do to install it, but you probably want to use a common path for your libs.

I usually put it in ~/Documents and create a symbolic link in /opt, because f\*\*k ~/.local/lib, right?:

```shell
git clone https://github.com/ingroxd/sheli.git ~/Documents/sheli
ln -s /home/user/Documents/sheli /opt/sheli
```

This is *personal* and you can (should, actually) use the path you prefer the most.

## Running the tests

In order to use it, just put in your script the following:
```shell
readonly SHELI_DIR='/path/to/sheli'
. "${SHELI_DIR}/sheli.sh"
```

Please, note that $SHELI\_DIR is mandatory and an error will be thrown if not declared.

Try copy-pasting this short script:
```bash
#!/bin/bash

readonly SHELI_DIR='/opt/sheli'
. "${SHELI_DIR}/sheli.sh"

sheli__main "${@}"
```

If everything works as intended, **you will have an error** for NOT having a main function.

## Deployment

In your script, you have to declare some variables and some functions.
In the repo there is an example script with additional memos.

Long story short, all you have to declare are the options your script needs (through argparse) and a main function.

The function main() is mandatory and an error will be thrown if not declared.

Optionally, you can declare functions as trap\_\_int, trap\_\_cleanup, trap\_\_die, etc.

## Contributing

If you think something could be more flexible/yellow/robust/modular/fast/something, **please**, you are welcome to suggest/edit/fork/whatever in order to help this project grow!

I will be happy to explain why I made some strange choices in coding, **but** I will be happier to hear suggestions and some healthy criticism to improve code and myself.

## Authors

* **Gregorio Casa** - *Initial work* - [ingroxd](https://github.com/ingroxd)

See also the list of [contributors](https://github.com/ingroxd/sheli/contributors) who participated in this project.

## License

This project is licensed under the GNU-GPLv3 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* This project was born because of those repetitive tasks I always have to write for every script.
* Please, bear in mind that the aim of this project is NOT efficiency (in terms of speed).
* Warning: not actually scrumpadoochous

