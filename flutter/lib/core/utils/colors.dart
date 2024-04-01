
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class GlobalColor {
  static HexColor mainColor = HexColor('#7D0A0A');
  static HexColor buttonColor = HexColor('#000000');
  static HexColor textColor = HexColor('#F3F8FF');
}

class SliderColor {
  static HexColor green1 = HexColor('#44b514');
  static HexColor green2 = HexColor('#57b514');
  static HexColor green3 = HexColor('#55b013');
  static HexColor green4 = HexColor('#4db304');
  static HexColor green5 = HexColor('#44b514');
  static HexColor green6 = HexColor('#56b811');
  static HexColor green7 = HexColor('#47a108');
  static HexColor green8 = HexColor('#55a113');
  static HexColor green9 = HexColor('#62a60f');
  static HexColor green10 = HexColor('#56910d');
  static HexColor green11 = HexColor('#6fad0a');
  static HexColor green12 = HexColor('#8dbf0d');
  static HexColor yellow1 = HexColor('#dbd804');
  static HexColor yellow2 = HexColor('#d1ce11');
  static HexColor yellow3 = HexColor('#bfbc04');
  static HexColor yellow4 = HexColor('#bfa604');
  static HexColor yellow5 = HexColor('#b58005');
  static HexColor yellow6 = HexColor('#b57205');
  static HexColor yellow7 = HexColor('#b55105');
  static HexColor yellow8 = HexColor('#b53405');
  static HexColor red = HexColor('#752204');
}

Color getColorByBox(String colorBox) {
  switch (colorBox) {
    case 'white':
      return Colors.grey[300]!;
    case 'green1':
      return SliderColor.green1;
    case 'green2':
      return SliderColor.green2;
    case 'green3':
      return SliderColor.green3;
    case 'green4':
      return SliderColor.green4;
    case 'green5':
      return SliderColor.green5;
    case 'green6':
      return SliderColor.green6;
    case 'green7':
      return SliderColor.green7;
    case 'green8':
      return SliderColor.green8;
    case 'green9':
      return SliderColor.green9;
    case 'green10':
      return SliderColor.green10;
    case 'green11':
      return SliderColor.green11;
    case 'green12':
      return SliderColor.green12;
    case 'yellow1':
      return SliderColor.yellow1;
    case 'yellow2':
      return SliderColor.yellow2;
    case 'yellow3':
      return SliderColor.yellow3;
    case 'yellow4':
      return SliderColor.yellow4;
    case 'yellow5':
      return SliderColor.yellow5;
    case 'yellow6':
      return SliderColor.yellow6;
    case 'yellow7':
      return SliderColor.yellow7;
    case 'yellow8':
      return SliderColor.yellow8;
    default:
      return SliderColor.red;
  }
}