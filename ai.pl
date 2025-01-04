% ai.pl
% Implements AI players with different strategies

% choose_move(+GameState, +Moves, +PlayerType, -Move)
% Human Player: Prompts user for move
choose_move(_, Moves, human, ChosenMove) :-
    write('Enter the number of the move you want to make: '),
    nl,
    read(Index),
    (   integer(Index),
        Index >= 1,
        length(Moves, Len),
        Index =< Len,
        nth1(Index, Moves, ChosenMove),
        !
    ;   write('Invalid choice. Please try again.'),
        nl,
        choose_move(_, Moves, human, ChosenMove)
    ).

% Random AI: Chooses a random move
choose_move(_, Moves, computer, Move) :-
    write('AI (Computer) selecting a random move...'), nl,
    random_member(Move, Moves),
    format("AI selected Move: ~w~n", [Move]).

% Smart AI: Tries to win, tries to stop you from winning, if he can't, just plays randomly
choose_move(GameState, Moves, strong_computer, Move) :-
    write('AI (Strong Computer) selecting a smart move...'), nl,
    choose_move_helper(GameState, Moves, Move),
    format("AI selected Move: ~w~n", [Move]).
    
% choose_move_helper(+GameState, +Moves, -Move)
% Helper function to find the next move for the smart ai
% Try to find a winning move
choose_move_helper(GameState, Moves, Move) :-
    find_winning_move(GameState, Moves, Move),
    write('Found winning move!'), nl,
    !.

% If no winning move, try to find a blocking move
choose_move_helper(GameState, Moves, Move) :-
    find_blocking_move(GameState, Moves, Move),
    write('Found blocking move!'), nl,
    !.

% If neither, choose a random move
choose_move_helper(_, Moves, Move) :-
    random_member(Move, Moves),
    write('No special moves found, choosing random move.'), nl.

% find_winning_move(+GameState, +Moves, -WinMove)
% Check if there's a winning move
find_winning_move(GameState, Moves, WinMove) :-
    current_player(GameState, CurrentPlayer),
    member(WinMove, Moves),
    % Try the move
    move(GameState, WinMove, NewState),
    % Check if it leads to a win
    game_over(NewState, Winner),
    Winner = CurrentPlayer.

% find_blocking_move(+GameState, +Moves, -BlockMove)
% Determines a move that blocks the opponent's potential winning move.
find_blocking_move(GameState, Moves, BlockMove) :-
    % Get current game state information
    state(Board, _, CurrentPlayer, _) = GameState,
    % Get opponent
    next_player(CurrentPlayer, NextPlayer),
    player_color(NextPlayer, NextPlayerColor),
    
    % Collect all board positions (X,Y,Size) where NextPlayer would win if they placed a piece
    findall((X, Y, Size), % Template
        (
          between(1, 3, X), % Iterate all X positions
          between(1, 3, Y), % Iterate all Y positions
          member(Size, [small, medium, large]), % For each size
          % Check that (X,Y) is empty for that Size
          member(cell(X, Y, Slots), Board),
          member(slot(Size, empty), Slots),
          
          % Temporarily place enemy's piece there, then check if that yields a 3-in-a-row
          replace_cell(Board, X, Y, Size, NextPlayerColor, TempBoard),
          check_win(TempBoard, NextPlayerColor)
        ),
        BlockPositions % Place them all in block position
    ),
  
    % If there are no block positions, this predicate fails
    BlockPositions \= [],

    % Look for a move in your valid moves that blocks at least one of those threat positions
    member(BlockMove, Moves),
    ( % Look for a place or move move that will block said position
        BlockMove = [place, Xb, Yb, Sizeb]
    ;   
        BlockMove = [move, _, _, Sizeb, Xb, Yb] 
    ),
    member((Xb, Yb, Sizeb), BlockPositions),

    % Cut so we only pick the first blocking move
    !.
