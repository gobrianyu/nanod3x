import 'package:flutter/material.dart';

const Color darkestGreen = Color(0xff1e2019);
const Color lightBeige = Color.fromARGB(255, 248, 245, 243);
const Color lightGreen = Color.fromARGB(255, 181, 185, 158);
const Color darkGreen = Color.fromARGB(255, 43, 43, 39);
const Color lightestGreen = Color.fromARGB(255, 227, 227, 215);

const Color midBlue = Color(0xff587b7f);
const Color brown = Color(0xff6b6054);
const Color lightBrown = Color(0xff929487);
const Color lightBlue = Color(0xffa1b0ab);
const Color mintGreen = Color(0xffc3dac3);
const Color lightGrey = Color.fromARGB(255, 226, 226, 226);
const Color darkGrey = Color.fromARGB(255, 54, 54, 52);

Color bgColour(bool darkMode) => darkMode ? darkestGreen : lightBeige;
Color tagColour(bool darkMode) => darkMode ? darkGreen : brown;
Color headerBgColour(bool darkMode) => darkMode ? darkGreen : brown;
Color accColour(bool darkMode) => darkMode ? brown : lightBrown;
Color regText(bool darkMode) => darkMode ? lightBeige : darkestGreen;
Color regionHeaderColour(bool darkMode) => darkMode ? brown : lightBrown;
Color lightText() => lightBeige;
Color darkText() => darkestGreen;
Color paneColour(bool darkMode) => darkMode ? darkGreen : lightGrey;
Color paneHeaderColour(bool darkMode) => darkMode ? darkestGreen : darkGreen;
Color invertTextColour(bool darkMode) => darkMode ? lightText() : darkText();

Color tileShadowColour(bool darkMode) => darkMode ? lightText() : Colors.black;

Color fallbackPane(bool darkMode) => darkMode ? darkGrey : lightGrey;
Color imageColour(bool darkMode) => darkMode ? lightBeige : Colors.white;