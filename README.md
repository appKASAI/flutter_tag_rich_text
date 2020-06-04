# tag_rich_text

RichTextを決められたタグを使うことで、Stringの文字列から作成することができます。

## Getting Started

```
dependencies:
  ...
  sqflite: 1.0.1
```



## Usage example

Import `tag_rich_text.dart`

```
import 'package:tag_rich_text.dart/tag_rich_text.dart.dart';
```



Use tags in alphabetical order(<b><i></i></b> is OK. <i><b></b></i> is NG). However, the link is the most central.

The types of tags that can be used are bold(b), color, italic(i), size, underline(u), link

 ## Example

 \<b><color=#800000>This color is #800000 and bold. \</color>\</b><size=30>\<u>\<link=https://www.google.co.jp/>This is underline and link. Size is 30\</link>\</u>\</size>

(https://user-images.githubusercontent.com/52235899/83761760-b2f45280-a6b1-11ea-99fc-e159417f949b.jpg)