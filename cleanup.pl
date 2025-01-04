% cleanup.pl
% Handles cleanup of dynamic predicates and game state between sessions

% Declare dynamic predicates that need to be cleaned up
:- dynamic cell/3.
:- dynamic game_config/3.
:- dynamic state/4.
:- dynamic progress/2.

% clear_data/0
% Removes all dynamic facts and rules between game sessions
clear_data :-
    retractall(cell(_, _, _)),
    retractall(game_config(_, _, _)),
    retractall(state(_, _, _, _)),
    retractall(progress(_, _)).

% Ensure cleanup happens at the start of each game
:- initialization(clear_data).