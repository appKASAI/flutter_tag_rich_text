library tag_rich_text;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum TextPropaty {
  bold,
  color,
  italic,
  size,
  underline,
  link,
  fin,
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

///Use tags in alphabetical order(<b><i></i></b> is OK. <i><b></b></i> is NG). However, the link is the most central.
///The types of tags that can be used are bold(b), color, italic(i), size, underline(u), link
///example "<b><color=#800000>This color is #800000 and bold. </color></b><size=30><u><link=https://www.google.co.jp/>This is underline and link. Size is 30</link></u></size>"
class TagRichText extends StatelessWidget {
  const TagRichText({Key key, this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return _makingRichText(text);
  }

  RichText _makingRichText(String body) {
    for (var i = 0; i < TextPropaty.values.length; i++) {}
    return RichText(
      text: TextSpan(
          children: _recursion(
        body,
        TextPropaty.bold,
      )),
    );
  }

  List<InlineSpan> _recursion(String partStr, TextPropaty propaty) {
    final map = _checkEnum(propaty);
    RegExp startRegExp = map['start'];
    RegExp endRegExp = map['end'];
    TextPropaty nextPropaty = map['next'];

    final bodies = partStr.split(startRegExp);
    final factors = startRegExp.allMatches(partStr).map((e) {
      final list = e.group(0).split(RegExp(r'[=>]'));
      return partStr.contains('=') ? list[1] : list[0];
    }).toList();

    List<String> strs;

    final spans = <InlineSpan>[];

    for (var i = 0; i < bodies.length; i++) {
      strs = bodies[i].split(endRegExp);

      if (strs.length >= 2) {
        for (var k = 0; k < strs.length; k++) {
          if (k == 0) {
            spans.add(
              _textSpan(propaty, nextPropaty, strs[k], factors[i - 1]),
            );
          } else {
            if (strs[k] != '') {
              spans.add(
                TextSpan(
                  children: nextPropaty != TextPropaty.fin
                      ? _recursion(strs[k], nextPropaty)
                      : [TextSpan(text: '')],
                  text: nextPropaty != TextPropaty.fin ? '' : strs[k],
                  style: propaty == TextPropaty.color
                      ? TextStyle(color: Colors.black)
                      : null,
                ),
              );
            }
          }
        }
      } else if (strs.length == 1) {
        if (strs[i] != '') {
          spans.add(
            TextSpan(
              children: nextPropaty != TextPropaty.fin
                  ? _recursion(strs[i], nextPropaty)
                  : [TextSpan(text: '')],
              text: nextPropaty != TextPropaty.fin ? '' : strs[i],
              style: propaty == TextPropaty.color
                  ? TextStyle(color: Colors.black)
                  : null,
            ),
          );
        }
      }
    }
    return spans;
  }

  TextSpan _textSpan(
      TextPropaty propaty, TextPropaty nextPropaty, String str, String factor) {
    switch (propaty) {
      case TextPropaty.bold:
        return TextSpan(
            children: nextPropaty != TextPropaty.fin
                ? _recursion(str, nextPropaty)
                : [TextSpan(text: '')],
            text: nextPropaty != TextPropaty.fin ? '' : str,
            style: TextStyle(fontWeight: FontWeight.bold));
        break;
      case TextPropaty.color:
        Color color = HexColor.fromHex(factor);
        return TextSpan(
            children: nextPropaty != TextPropaty.fin
                ? _recursion(str, nextPropaty)
                : [TextSpan(text: '')],
            text: nextPropaty != TextPropaty.fin ? '' : str,
            style: TextStyle(color: color));
        break;
      case TextPropaty.italic:
        return TextSpan(
            children: nextPropaty != TextPropaty.fin
                ? _recursion(str, nextPropaty)
                : [TextSpan(text: '')],
            text: nextPropaty != TextPropaty.fin ? '' : str,
            style: TextStyle(fontStyle: FontStyle.italic));
        break;
      case TextPropaty.size:
        return TextSpan(
            children: nextPropaty != TextPropaty.fin
                ? _recursion(str, nextPropaty)
                : [TextSpan(text: '')],
            text: nextPropaty != TextPropaty.fin ? '' : str,
            style: TextStyle(fontSize: double.parse(factor)));
        break;
      case TextPropaty.underline:
        return TextSpan(
            children: nextPropaty != TextPropaty.fin
                ? _recursion(str, nextPropaty)
                : [TextSpan(text: '')],
            text: nextPropaty != TextPropaty.fin ? '' : str,
            style: TextStyle(decoration: TextDecoration.underline));
        break;

      case TextPropaty.link:
        return TextSpan(
          children: nextPropaty != TextPropaty.fin
              ? _recursion(str, nextPropaty)
              : [TextSpan(text: '')],
          text: nextPropaty != TextPropaty.fin ? '' : str,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(factor);
            },
        );
        break;
      default:
        return null;
    }
  }

  Map<String, dynamic> _checkEnum(TextPropaty propaty) {
    final map = <String, dynamic>{};
    RegExp startRegExp;
    RegExp endRegExp;
    TextPropaty nextPropaty;
    switch (propaty) {
      case TextPropaty.bold:
        startRegExp = RegExp(r'<b>');
        endRegExp = RegExp(r'</b>');
        nextPropaty = TextPropaty.color;
        break;

      case TextPropaty.color:
        startRegExp = RegExp(r'<color=(.+?)>');
        endRegExp = RegExp(r'</color>');
        nextPropaty = TextPropaty.italic;
        break;
      case TextPropaty.italic:
        startRegExp = RegExp(r'<i>');
        endRegExp = RegExp(r'</i>');
        nextPropaty = TextPropaty.size;
        break;

      case TextPropaty.size:
        startRegExp = RegExp(r'<size=(.+?)>');
        endRegExp = RegExp(r'</size>');
        nextPropaty = TextPropaty.underline;
        break;

      case TextPropaty.underline:
        startRegExp = RegExp(r'<u>');
        endRegExp = RegExp(r'</u>');
        nextPropaty = TextPropaty.link;
        break;

      case TextPropaty.link:
        startRegExp = RegExp(r'<link=(.+?)>');
        endRegExp = RegExp(r'</link>');
        nextPropaty = TextPropaty.fin;
        break;
      case TextPropaty.fin:
    }

    map.addAll({'start': startRegExp, 'end': endRegExp, 'next': nextPropaty});

    return map;
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (c) {
      print(c);
    }
  }
}
