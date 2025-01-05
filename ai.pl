% ai.pl
% Implements AI players with different strategies

% validate_move(+Index, +Moves, -ChosenMove)
% Validate the move chosen by human player 
validate_move(Index, Moves, ChosenMove) :-
    integer(Index),
    Index >= 1,
    length(Moves, Len),
    Index =< Len,
    nth1(Index, Moves, ChosenMove),
    !.

% Case where it is invalid user input
validate_move(_, Moves, ChosenMove) :-
    write('Invalid choice. Please try again.'),
    nl,
    choose_move(_, Moves, human, ChosenMove).

% choose_move(+GameState, +Moves, +PlayerType, -Move)
% Human Player: Prompts user for move, and validate said move
choose_move(_, Moves, human, ChosenMove) :-
    write('Enter the number of the move you want to make: '),
    nl,
    read(Index),
    validate_move(Index, Moves, ChosenMove).

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
% Determines a move that blocks the opponent's potential winning move
find_blocking_move(GameState, Moves, BlockMove) :-
    % Get current game state information
    state(Board, _, CurrentPlayer, _) = GameState,
    % Get opponent
    next_player(CurrentPlayer, NextPlayer),
    player_color(NextPlayer, NextPlayerColor),

    % Collect all board positions (X, Y, Size) where NextPlayer would win if they placed a piece
    find_block_positions(Board, NextPlayerColor, BlockPositions),
    BlockPositions \= [],

    % Find a move that blocks at least one of those threat positions 
    find_blocking_move_in_list(Moves, BlockPositions, BlockMove).

% find_block_positions(+Board, +NextPlayerColor, -BlockPositions)
% Finds all board positions where the opponent could win
find_block_positions(Board, NextPlayerColor, BlockPositions) :-
    findall((X, Y, Size), 
        (
            between(1, 3, X), % Iterate all X positions
            between(1, 3, Y), % Iterate all Y positions
            member(Size, [small, medium, large]), % For each size
            member(cell(X, Y, Slots), Board),
            member(slot(Size, empty), Slots),
            
            % Temporarily place opponent's piece there and check if it results in a win
            replace_cell(Board, X, Y, Size, NextPlayerColor, TempBoard),
            check_win(TempBoard, NextPlayerColor)
        ),
        BlockPositions).

% find_blocking_move_in_list(+Moves, +BlockPositions, -BlockMove)
% Finds a move in the list of valid moves that blocks a threat position
find_blocking_move_in_list([Move | _], BlockPositions, Move) :-
    blocks_position(Move, BlockPositions), !. % Try to match the head of the moves to a vald BlockPosition, and stop the backtrack on first match
find_blocking_move_in_list([_ | Rest], BlockPositions, BlockMove) :-
    find_blocking_move_in_list(Rest, BlockPositions, BlockMove). % Recursive case, call the function on the Rest of the Block Positions

% blocks_position(+Move, +BlockPositions)
% Checks if a move blocks any position in the list of block positions
blocks_position([place, X, Y, Size], BlockPositions) :-
    member((X, Y, Size), BlockPositions). % See if we have a valid place move to block the position
blocks_position([move, _, _, Size, X, Y], BlockPositions) :-
    member((X, Y, Size), BlockPositions). % See if we have a valid move move to block the position
