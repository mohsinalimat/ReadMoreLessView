ReadMoreLessView
===========
![Language](https://img.shields.io/badge/language-Swift%202-orange.svg)
![License](https://img.shields.io/packagist/l/doctrine/orm.svg)

ReadMoreLessView is written in Swift. This custom view can be used instead of a UILabel when there is necessity to show a short part of a full text but with the possibility to expand the label to show the full text. A read more/read less button allow the text to be expanded or collapsed. 

It’s possible to customise font and colour of the title, the body and the button (read more/less). 

## Usage

1. Change the class of a UIView to ReadMoreLessView;
2. Programmatically set a new String for the title and/or for the body: 
```
readMoreLessView.setText(titleText, body: bodytext)
```
![Demo](Images/Demo.gif?raw=true "Optional Title")

Created by
Stefano Frosoni, [@stefanofrosoni](http://twitter.com/stefanofrosoni)