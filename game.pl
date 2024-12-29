% game.pl;
% Displays the game menu / Reads the configuration / Starts the game loop;

:- use_module(library(random)).
:- use_module(library(between)).
:- use_module(library(lists)).
:- [display, moves, rules, state]. 
% include .pl files and libraries;

% initialize game;
play :-
    display_menu, 
    read_configuration(GameConfig),
    initial_state(GameConfig, GameState),
    game_cycle(GameState).

% print the menu;
display_menu :-
    write('Welcome to ~ Aqua Pipe ~ by Bruno and Goncalo'), nl,
    write('Choose your game mode:'), nl,
    write('(1.) Human vs Human (H/H)'), nl,
    write('(2.) Human vs Computer (H/PC)'), nl,
    write('(3.) Human vs Strong Computer (H/PC)'), nl,
    write('(4.) Strong Computer vs Strong Computer (PC/PC)'), nl,
    write('(5.) Quit'), nl.

player_color(player1, blue).
player_color(player2, red).

% read the configuration, verify the input, if invalid keep reading;
read_configuration(GameConfig) :-
    read(Option),
    (configure_game(Option, GameConfig) ->
        (GameConfig = quit -> write('Goodbye!'), nl, halt;
         GameConfig = game_config(_, _, _, StartingPlayer), write(''), nl,
         format("The starting player is: ~w~n", [StartingPlayer]))
        ;
        write('Invalid option, please try again.'), nl,
        read_configuration(GameConfig)
    ).

coin_toss(Player) :-
    random(RandomFloat),
    (RandomFloat < 0.5 -> Player = player1; Player = player2).

configure_game(1, game_config(human, human, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(2, game_config(human, computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(3, game_config(human, strong_computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(4, game_config(strong_computer, strong_computer, normal, StartingPlayer)) :- coin_toss(StartingPlayer).
configure_game(5, quit).

% Game cycle;
game_cycle(GameState) :-
    (game_over(GameState, Winner) ->
        format("Game over! The winner is: ~w~n", [Winner]) 
    ;   
        current_player(GameState, CurrentPlayer),
        display_game(GameState),
        valid_moves(GameState, Moves),                     
        display_moves(Moves),
        choose_move(Moves, ChosenMove),
        move(GameState, ChosenMove, NewGameState),
        write('Move executed successfully.'), nl,
        game_cycle(NewGameState)             
    ).

% Extract the current player from the game state;
current_player(state(_, _, CurrentPlayer, _), CurrentPlayer).

% next_player(+CurrentPlayer, -NextPlayer)
next_player(player1, player2).
next_player(player2, player1).


% Allow the player to choose a move from the list of valid moves.
choose_move(Moves, ChosenMove) :-
    write('Enter the number of the move you want to make: '), nl,
    read(Index),                            
    nth1(Index, Moves, ChosenMove),          
    !.                                      
choose_move(Moves, ChosenMove) :-
    write('Invalid choice. Please try again.'), nl,
    choose_move(Moves, ChosenMove).          



