% ai.pl
% Implements AI players with different strategies

% Human Player: Prompts user for move
choose_move(_, Moves, human, ChosenMove) :-
    display_moves_with_indices(Moves),
    write('Enter the number of the move you want to make: '), nl,
    read(Index),
    ( 
        integer(Index), 
        Index >= 1, 
        length(Moves, Len),
        Index <= Len,
        nth1(Index, Moves, ChosenMove),
        !
    ;
        write('Invalid choice. Please try again.'), nl,
        choose_move(_, Moves, human, ChosenMove)
    ).

% Random AI: Chooses a random move
choose_move(_, Moves, computer, Move) :-
    write('AI (Computer) selecting a random move...'), nl,
    random_member(Move, Moves),
    format("AI selected Move: ~w~n", [Move]).

% Strong Computer AI with win detection and blocking
choose_move(GameState, Moves, strong_computer, Move) :-
    write('AI (Strong Computer) selecting a smart move...'), nl,
    (win_move(GameState, Moves, WinMove) -> 
        Move = WinMove,
        write('Found winning move!'), nl
    ;
    block_move(GameState, Moves, BlockMove) ->
        Move = BlockMove,
        write('Found blocking move!'), nl
    ;
    strategic_move(GameState, Moves, StratMove) ->
        Move = StratMove,
        write('Using strategic move.'), nl
    ;
    random_member(Move, Moves),
    write('No special moves found, choosing random move.'), nl
    ).

% Check if there's a winning move
win_move(GameState, Moves, Move) :-
    member(Move, Moves),
    move(GameState, Move, NewState),
    game_over(NewState, Winner),
    current_player(GameState, Player),
    Winner = Player.

% Check if we need to block opponent's winning move
block_move(GameState, Moves, Move) :-
    current_player(GameState, Player),
    next_player(Player, Opponent),
    member(Move, Moves),
    move(GameState, Move, NewState),
    \+ (valid_moves(NewState, OpponentMoves),
        member(OpponentMove, OpponentMoves),
        move(NewState, OpponentMove, FinalState),
        game_over(FinalState, Opponent)).

% Strategic move prioritization
strategic_move(GameState, Moves, Move) :-
    state(Board, _, CurrentPlayer, _) = GameState,
    findall(Score-M, (
        member(M, Moves),
        evaluate_move(Board, M, CurrentPlayer, Score)
    ), ScoredMoves),
    keysort(ScoredMoves, [_-Move|_]).

% Evaluate move based on position control and piece sizes
evaluate_move(Board, [place, X, Y, Size], Player, Score) :-
    evaluate_position_score(X, Y, PositionScore),
    evaluate_size_score(Size, SizeScore),
    Score is PositionScore + SizeScore.
evaluate_move(Board, [move, X1, Y1, Size, X2, Y2], Player, Score) :-
    evaluate_position_score(X2, Y2, NewPositionScore),
    evaluate_position_score(X1, Y1, OldPositionScore),
    evaluate_size_score(Size, SizeScore),
    Score is NewPositionScore - OldPositionScore + SizeScore.

% Position scoring (center and corners are valuable)
evaluate_position_score(2, 2, 3).  % Center
evaluate_position_score(X, Y, 2) :- % Corners
    (X = 1; X = 3),
    (Y = 1; Y = 3).
evaluate_position_score(_, _, 1).  % Other positions

% Size scoring (larger pieces are more valuable)
evaluate_size_score(large, 3).
evaluate_size_score(medium, 2).
evaluate_size_score(small, 1).