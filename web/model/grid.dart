part of snakesnladders;

class Tile extends CellPiece {
  static const String tileColor = 'lightyellow';
  static const String tagColor = 'black';
  
  Tile(TileGrid grid, Cell cell) {
    this.grid = grid;
    this.cell = cell;
    color.main = tileColor;
    isTagged = true;
    tag.size = 24;
    tag.color.main = tagColor;
    tag.number = grid.getGamePositionByCell(cell);
  }
}

class TileGrid extends Grid {
  TileGrid(Table table): super(table) {}

  /// Get new Cell instance by numeric position (1-100)
  Cell getCellByGamePosition(num position) {
    num column, row;
    row = rowCount - ((position - 1) / rowCount).floor() - 1;
    bool normalDirection = (row % 2 == 1);

    if (normalDirection) {
      // Normal direction
      column = (position - 1) % columnCount;
    } else {
      // Reverse direction
      column = columnCount - ((position - 1) % columnCount) - 1;
    }

    return new Cell.from(column, row);
  }

  /// Get numeric position (1-100) by Cell
  num getGamePositionByCell(Cell cell) {
    if (cell.row % 2 == 0) {
      // Normal direction
      return (rowCount - cell.row) * columnCount - cell.column;
    } else {
      // Reverse direction
      return (rowCount - cell.row - 1) * columnCount + cell.column + 1;
    }
  }
  
  CellPiece newCellPiece(Grid grid, Cell cell) => new Tile(this, cell);
}

class Player extends CellPiece {
  num _position, idx;
  String playerColor;

  Player(TileGrid grid, Cell cell, String playerColor, num idx) {
    this.grid = grid;
    this.cell = cell;
    this.playerColor = playerColor;
    color.main = playerColor;
    shape = PieceShape.CIRCLE;
    width = grid.cellWidth / 5;
    height = grid.cellWidth / 5;

    // Setting player index
    this.idx = idx;

    // Setting initial position for the player
    gamePosition = grid.getGamePositionByCell(cell);
  }

  updatePosition() {
    /// Updates X,Y of the player based on the current position
    x = grid.cellWidth * cell.column + (2 + width) * idx + 5;
    y = grid.cellHeight * cell.row + grid.cellHeight - height - 5;
  }

  num get gamePosition => _position;
  void set gamePosition(num position) {
    _position = position;
    cell = (grid as TileGrid).getCellByGamePosition(position);

    updatePosition();
  }
}

class Players extends CellPieces {
  num nextPlayerIdx = 0;

  Players(TileGrid grid, List<String> playerColors) {
    this.grid = grid;
    num idx = 0;
    for (var playerColor in playerColors) {
      add(new Player(grid, grid.getCellByGamePosition(1), playerColor, idx));
      idx++;
    }
  }

  nextPlayer() {
    for (Player p in this) {
      if (p.idx == nextPlayerIdx) {
        nextPlayerIdx++;
        if (nextPlayerIdx >= length) {
          nextPlayerIdx = 0;
        }
        return p;
      }
    }
  }
}

class Arrow extends Piece {
  static const String ladderColor = 'green';
  static const String snakeColor = 'red';

  bool isSnake;
  num startPosition;
  num stopPosition;
  TileGrid grid;

  Arrow(TileGrid grid, startPosition, stopPosition) {
    this.isSnake = (stopPosition < startPosition);
    this.startPosition = startPosition;
    this.stopPosition = stopPosition;
    this.grid = grid;
  }

  draw(canvas, imgLadder, imgSnake) {
    Cell startCell = grid.getCellByGamePosition(startPosition);
    Cell stopCell = grid.getCellByGamePosition(stopPosition);

    //String arrowColor = isSnake ? snakeColor : ladderColor;

    num x1 = grid.cellWidth * startCell.column + grid.cellWidth / 2;
    num y1 = grid.cellHeight * startCell.row + grid.cellHeight / 2;
    num x2 = grid.cellWidth * stopCell.column + grid.cellWidth / 2;
    num y2 = grid.cellHeight * stopCell.row + grid.cellHeight / 2;

    ImageElement imgToDraw;

    if (isSnake) {
      num tempX, tempY;
      tempX = x1; tempY = y1;
      x1 = x2; y1 = y2;
      x2 = tempX; y2 = tempY;

      imgToDraw = imgSnake;
    } else {
      imgToDraw = imgLadder;
    }

    num angle = atan2(y2 - y1, x2 - x1);
    num scaledImgHeight = sqrt(pow(y2 - y1, 2) + pow(x2 - x1, 2));

    // num headLen = 20;
    // drawLine(canvas, x1, y1, x2, y2, lineWidth: 2, color: arrowColor);
    // drawLine(canvas, x2, y2, x2 - headLen * cos(angle-PI/6), y2 - headLen * sin(angle-PI/6), lineWidth: 2, color: arrowColor);
    // drawLine(canvas, x2, y2, x2 - headLen * cos(angle+PI/6), y2 - headLen * sin(angle+PI/6), lineWidth: 2, color: arrowColor);

    var ctx = canvas.getContext('2d');

    ctx
      ..save()
      ..globalAlpha = 0.75
      ..translate(x1, y1)
      ..rotate(angle + PI/2)
      ..beginPath()
      ..drawImageToRect(imgToDraw, new Rectangle(-imgToDraw.width / 2, -scaledImgHeight, imgToDraw.width, scaledImgHeight))
      ..closePath()
      ..restore();
  }
}

class Arrows extends Pieces {
  TileGrid grid;
  List boundPositions = new List();
  num startPosition, stopPosition;

  Arrows(TileGrid grid) {
    this.grid = grid;
    Arrow arrow;

    for (num i = 0; i < 3; i++) {
      // Add ladders
      while (true) {
        startPosition = new Random().nextInt(70) + 5;
        if (boundPositions.indexOf(startPosition) != -1) {
          continue;
        }
        stopPosition = new Random().nextInt(70) + 25;
        if (stopPosition - startPosition <= 25 || boundPositions.indexOf(stopPosition) != -1) {
          continue;
        }

        arrow = new Arrow(grid, startPosition, stopPosition);
        bool hasIntersection = any((a) {
          return !a.isSnake && detectArrowsIntersection(arrow, a);
        });
        if (!hasIntersection) {
          break;
        }
      }
      add(arrow);
      boundPositions
        ..add(startPosition)
        ..add(stopPosition);

      // Add snakes
      while (true) {
        startPosition = new Random().nextInt(70) + 25;
        if (boundPositions.indexOf(startPosition) != -1) {
          continue;
        }
        stopPosition = new Random().nextInt(70) + 5;
        if (startPosition - stopPosition <= 25 || boundPositions.indexOf(stopPosition) != -1) {
          continue;
        }

        arrow = new Arrow(grid, startPosition, stopPosition);
        bool hasIntersection = any((a) {
          return a.isSnake && detectArrowsIntersection(arrow, a);
        });
        if (!hasIntersection) {
          break;
        }
      }
      add(new Arrow(grid, startPosition, stopPosition));
      boundPositions
        ..add(startPosition)
        ..add(stopPosition);
    }
  }

  bool detectArrowsIntersection(Arrow arrow1, Arrow arrow2) {
    Cell a = grid.getCellByGamePosition(arrow1.startPosition);
    Cell b = grid.getCellByGamePosition(arrow1.stopPosition);
    Cell c = grid.getCellByGamePosition(arrow2.startPosition);
    Cell d = grid.getCellByGamePosition(arrow2.stopPosition);

    num denominator = ((b.column - a.column) * (d.row - c.row)) - ((b.row - a.row) * (d.column - c.column));
    num numerator1 = ((a.row - c.row) * (d.column - c.column)) - ((a.column - c.column) * (d.row - c.row));
    num numerator2 = ((a.row - c.row) * (b.column - a.column)) - ((a.column - c.column) * (b.row - a.row));

    if (denominator == 0) return numerator1 == 0 && numerator2 == 0;

    num r = numerator1 / denominator;
    num s = numerator2 / denominator;

    return (r >= 0 && r <= 1) && (s >= 0 && s <= 1);
  }

  arrowByPosition(num position) {
    for (Arrow a in this) {
      if (a.startPosition == position) {
        return a;
      }
    }
    return null;
  }
}
