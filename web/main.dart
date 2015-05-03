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
  var table = new Table.from(new Size.from(10, 10),
                             new Area.from(canvas.width, canvas.height));
  new Board(canvas, new TileGrid(table));
}
