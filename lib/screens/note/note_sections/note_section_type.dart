import 'package:flutter/material.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

enum NoteSectionType {
  textBox(
    title: "Text Box",
    description: "Shows the entered text in given formats.",
    icon: SvgIcon(
      XIcons.text,
      width: 20,
    ),
    data: {'text': ''},
    isContainer: false,
  ),
  imageBox(
    title: "Image Box",
    description: "Shows image from given network image url.",
    icon: SvgIcon(
      XIcons.image,
      width: 20,
    ),
    data: {'url': ''},
    isContainer: false,
  ),
  ytVideoBox(
    title: "YouTube Video Box",
    description: "Shows image from given network image url.",
    icon: SvgIcon(
      XIcons.youtube,
      width: 20,
    ),
    data: {'url': ''},
    isContainer: false,
  ),
  codeViewBox(
    title: "Code View Box",
    description: "Shows code in proper formatting.",
    icon: SvgIcon(
      XIcons.code,
      width: 20,
    ),
    data: {'code': '', 'lang': 'java'},
    isContainer: false,
  ),
  ;

  final String title;
  final String description;
  final Widget icon;
  final bool isContainer;
  final Map<String, dynamic> data;

  const NoteSectionType({
    required this.title,
    required this.description,
    required this.icon,
    required this.data,
    required this.isContainer,
  });

  Map<String, dynamic> getJson() {
    Map<String, dynamic> result = {'type': name};
    result.addAll(data);
    return result;
  }
}
