import 'package:flutter/material.dart';

class Data {
  final String parent;
  final String title;
  final String description;
  final int oldPrice;
  final int newPrice;
  final String details;
  final Widget redirection;
  final String photo;

  Data(
      {this.title,
      this.description,
      this.parent,
      this.details,
      this.oldPrice,
      this.newPrice,
      this.photo,
      this.redirection});
}
