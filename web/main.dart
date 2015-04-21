library snakesnladders;

import 'dart:html';
import 'dart:math';
import 'package:boarding/grid.dart';
import 'package:boarding/boarding.dart';
import 'package:boarding/util.dart';
import 'package:boarding/pieces.dart';

part 'model/grid.dart';
part 'view/board.dart';

main() {
  var canvas = querySelector('#canvas');
  var table = new Table(new Area(canvas.width, canvas.height), new Size(10, 10));
  new Board(canvas, new TileGrid(table)).draw();
}
