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

% Execute move and validate it's legal using a strong computer AI
choose_move(GameState, Moves, strong_computer, Move) :-
    write('AI (Strong Computer) selecting a smart move...'), nl,
    % First try to find a winning move
    (find_winning_move(GameState, Moves, WinningMove)
    -> Move = WinningMove,
       write('Found winning move!'), nl
    % If no winning move, try to find a blocking move
    ; find_blocking_move(GameState, Moves, BlockingMove)
    -> Move = BlockingMove,
       write('Found blocking move!'), nl
    % If no winning or blocking move, choose random
    ; random_member(Move, Moves),
       write('No special moves found, choosing random move.'), nl
    ).

% find_winning_move(+GameState, +Moves, -Move)
% Check if there's a winning move
find_winning_move(GameState, Moves, Move) :-
    current_player(GameState, CurrentPlayer),
    member(Move, Moves),
    % Try the move
    move(GameState, Move, NewState),
    % Check if it leads to a win
    game_over(NewState, Winner),
    Winner = CurrentPlayer.

% find_blocking_move(+GameState, +Moves, -Move)
% Check if we need to block opponent's winning move
find_blocking_move(GameState, Moves, Move) :-
    % Get current player and their opponent
    current_player(GameState, CurrentPlayer),
    next_player(CurrentPlayer, Opponent),
    
    % Try each possible move
    member(Move, Moves),
    move(GameState, Move, AfterMoveState),
    
    % Get opponent's possible responses
    valid_moves(AfterMoveState, OpponentMoves),
    
    % Check if NOT playing this move would let opponent win
    \+ (
        member(OpponentMove, OpponentMoves),
        move(AfterMoveState, OpponentMove, FinalState),
        game_over(FinalState, Winner),
        Winner = Opponent
    ).
