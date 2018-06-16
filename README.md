# chrome-dmenu
Search chrome bookmark and history using dmenu.

## Dependencies
* Python 3
* dmenu
* bash

## Usage
```
chrome-dmenu.sh [--history] [default_url]

OPTIONS:
  --history    history search mode
  default_url  set default url
```

## Examples
* Bookmark search

      $ chrome-dmenu.sh
* Historty search

      $ chrome-dmenu.sh --history
* Default URL is Google search with clipboard text

      $ chrome-dmenu.sh "http://www.google.com/search?q=`xclip -o -selection primary`"


## InputText
* Google search

      g search word(shift+return)
* DuckDuckGo search

      d search word(shift+return)
* Youtube search

      y search word(shift+return)
* GitHub search

      h search word(shift+return)
* History search mode

      H(shift+return)

## License
MIT License

