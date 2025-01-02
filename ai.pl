% ai.pl
% Implements AI players with different strategies

% Human Player: Prompts user for move
choose_move(_, Moves, human, ChosenMove) :-
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

% Execute move and validate it's legal using a strong computer AI
choose_move(GameState, Moves, strong_computer, Move) :-
    write('AI (Strong Computer) selecting a smart move...'), nl,
    % Check for any move that wins the game
    (   win_move(GameState, Moves, Move),
        write('Found winning move!'), nl
    )
    ; % Alternatively, check for a move to block enemy victory on next turn
    (   
        block_move(GameState, Moves, BlockMove),
        Move = BlockMove,
        write('Found blocking move!'), nl
    )
    ; % No smart moves available, just play a random move
    random_member(Moves, Move),
    write('No special moves found, choosing random move.'), nl.

% Check if there's a winning move
win_move(GameState, Moves, Move) :-
    member(Move, Moves),
    simulate_move(GameState, Move, NewState),
    game_over(NewState, Winner),
    current_player(GameState, Player),
    Winner = Player.

% Check if we need to block opponent's winning move
block_move(GameState, Moves, Move) :-
    current_player(GameState, Player),
    next_player(Player, Opponent),
    member(Move, Moves),
    simulate_move(GameState, Move, NewState),
    valid_moves(NewState, OpponentMoves),
    member(OpponentMove, OpponentMoves),
    move(NewState, OpponentMove, FinalState),
    game_over(FinalState, Opponent),
    !.
