//Ludum Dare 28 Sean Rabaut

import 'dart:html';
import 'game.dart';

void main() {
  var game = new Game();
  window.animationFrame.then(game.update);
}