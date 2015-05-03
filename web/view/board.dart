part of snakesnladders;

class Board extends Surface {
  bool isGameRunning = false;
  Players players;
  Player nextPlayer;
  Arrows arrows;
  TileGrid grid;

  ButtonElement btnNewGameElement = querySelector('#btn-start-game');
  DivElement statusElement = querySelector('#game-status');
  CanvasElement dieElement = querySelector('#die');
  AudioElement victorySound = querySelector('#audio-victory');

  ImageElement imgLadder = querySelector('#img-ladder1');
  ImageElement imgSnake = querySelector('#img-snake1');

  Board(CanvasElement canvas, TileGrid tileGrid) {
    this.canvas = canvas;
    grid = tileGrid;

    btnNewGameElement.onClick.listen((e) {
      List playerColors = querySelectorAll('#players > li > input')
        .where((InputElement c) => c.checked)
        .map((InputElement c) => c.classes.toList().elementAt(0))
        .toList();

      if (playerColors.length == 0) {
        window.alert('You need to select at least one player');
        return;
      }
      
      newGame(playerColors);
    });

    canvas.onClick.listen((e) {
      if (isGameRunning && !isGameOver) {
        nextTurn();

        if (!isGameOver) {
          prepareNextTurn();
        }
      }
    });

    // Preload victory victorySound
    victorySound.load();

    window.animationFrame.then(gameLoop);
  }
  
  draw() {
    super.draw();

    if (isGameRunning || isGameOver) {
      for (Arrow arrow in arrows) {
        arrow.draw(canvas, imgLadder, imgSnake);
      }
      for (Player player in players) {
        drawPiece(player);
      }
    }
  }

  newGame(playerColors) {
    players = new Players(grid, playerColors);
    arrows = new Arrows(grid);

    // Reset die indicator
    drawDieValue(0);

    // Stop victorySound
    victorySound.pause();
    victorySound.currentTime = 0;

    prepareNextTurn();

    isGameRunning = true;
    isGameOver = false;
  }

  prepareNextTurn() {
    nextPlayer = players.nextPlayer();
    statusElement.text = nextPlayer.playerColor + " player turn. Click on board to roll the dice";
  }

  nextTurn() {
    num nextMovesNumber = new Random().nextInt(6) + 1;
    drawDieValue(nextMovesNumber);

    if (nextPlayer.gamePosition + nextMovesNumber >= 100) {
      nextPlayer.gamePosition = 100;
      gameOver();
      return;
    } else {
      nextPlayer.gamePosition += nextMovesNumber;
      Arrow arrow = arrows.arrowByPosition(nextPlayer.gamePosition);
      if (arrow is Arrow) {
        // There is an arrow on the position
        nextPlayer.gamePosition = arrow.stopPosition;
      }
    }
  }

  gameOver() {
    isGameOver = true;
    statusElement.text = nextPlayer.playerColor + " player has won!";
    victorySound.play();
  }

  drawDieValue(num value) {
    /// Draws die value
    num width = dieElement.width;
    num height = dieElement.height;
    num dotSize = width / 10;

    CanvasRenderingContext2D ctx = dieElement.getContext('2d');

    ctx
      ..fillStyle = "#eeeeee"
      ..fillRect(0, 0, width, height)
      ..fillStyle = "#000000";

    switch (value) {
      case 1:
        ctx.fillRect(width / 2 - dotSize / 2, height / 2 - dotSize / 2, dotSize, dotSize);
        break;

      case 2:
        ctx
          ..fillRect(dotSize, dotSize, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height - dotSize * 2, dotSize, dotSize);
        break;

      case 3:
        ctx
          ..fillRect(width / 2 - dotSize / 2, height / 2 - dotSize / 2, dotSize, dotSize)
          ..fillRect(dotSize, dotSize, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height - dotSize * 2, dotSize, dotSize);
        break;

      case 4:
        ctx
          ..fillRect(dotSize, dotSize, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height - dotSize * 2, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, dotSize, dotSize, dotSize)
          ..fillRect(dotSize, height - dotSize * 2, dotSize, dotSize);
        break;

      case 5:
        ctx
          ..fillRect(width / 2 - dotSize / 2, height / 2 - dotSize / 2, dotSize, dotSize)
          ..fillRect(dotSize, dotSize, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height - dotSize * 2, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, dotSize, dotSize, dotSize)
          ..fillRect(dotSize, height - dotSize * 2, dotSize, dotSize);
        break;

      case 6:
        ctx
          ..fillRect(dotSize, dotSize, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height - dotSize * 2, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, dotSize, dotSize, dotSize)
          ..fillRect(dotSize, height - dotSize * 2, dotSize, dotSize)
          ..fillRect(dotSize, height / 2 - dotSize / 2, dotSize, dotSize)
          ..fillRect(width - dotSize * 2, height / 2 - dotSize / 2, dotSize, dotSize);
        break;

      default:
        // Do nothing
    }
  }
}