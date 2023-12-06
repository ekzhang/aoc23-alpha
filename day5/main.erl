% This solution is in Erlang. It's my first time using it, quite interesting!
%
% I found the expression-oriented syntax a little bit hard to get used to at first, especially for
% delimiters, but it wasn't too bad. Felt a bit trickier to read than OCaml or Haskell. Not having
% mutable variables was also a bit tricky, but otherwise fine! List comprehensions were nice. And
% this problem happens to be pretty amenable to functional programming.
%
% The emphasis on pattern-matching and delimiters reminds me a lot of Prolog. Actually, now that
% I search the history (https://www.erlang.org/faq/academic.html), it seems like Erlang was
% originally based on a modified version of Prolog. Score!
%
% Namespaces felt fine, and the ease of writing functions was a nice surprise.
%
% I tripped over the Erlang shell for 30 minutes until I figured out how to run my code. It's
% definitely not the most obvious tool for modern programmers used to CLI. Guess the Unix
% philosophy won out over the past 4 decades.
%
% In summary, lots of cool ideas and unfortunately also some quirks. But the old, OG languages have
% their charm, even if they're not super intuitive to programmers today. :')

-module(main).

-export([start/0]).

-record(data, {
    seeds = [] :: [integer()],
    maps = [] :: [[{integer(), integer(), integer()}]]
}).

% Read all of the lines from stdin and parse it into the data record.
%
% This creates an extra [] at the beginning of the maps list, which needs to be stripped off
% by the caller first.
parse_input() ->
    case io:get_line("") of
        eof ->
            #data{maps = [[]]};
        % Skip blank lines.
        "\n" ->
            parse_input();
        Line ->
            TrimmedLine = string:trim(Line, trailing),
            case string:prefix(TrimmedLine, "seeds:") /= nomatch of
                true ->
                    [_ | Seeds] = string:tokens(TrimmedLine, " "),
                    SeedsInt = lists:map(fun list_to_integer/1, Seeds),
                    Rest = parse_input(),
                    #data{seeds = SeedsInt, maps = Rest#data.maps};
                false ->
                    case string:find(TrimmedLine, "map:") /= nomatch of
                        true ->
                            #data{maps = Maps} = parse_input(),
                            #data{maps = [[] | Maps]};
                        false ->
                            [X, Y, Z] = lists:map(
                                fun list_to_integer/1, string:tokens(TrimmedLine, " ")
                            ),
                            #data{maps = [CurrentMap | Maps]} = parse_input(),
                            #data{maps = [[{X, Y, Z} | CurrentMap] | Maps]}
                    end
            end
    end.

to_location(Num, []) ->
    Num;
to_location(Num, [[] | Maps]) ->
    to_location(Num, Maps);
to_location(Num, [[{X, Y, Z} | Map] | Maps]) ->
    if
        Num >= Y andalso Num < Y + Z ->
            to_location(X + Num - Y, Maps);
        true ->
            to_location(Num, [Map | Maps])
    end.

min_range_to_location(Start, _, []) ->
    Start;
min_range_to_location(Start, End, [[] | Maps]) ->
    min_range_to_location(Start, End, Maps);
min_range_to_location(Start, End, [[{X, Y, Z} | Map] | Maps]) ->
    D = X - Y,
    if
        Start >= Y + Z orelse End =< Y ->
            min_range_to_location(Start, End, [Map | Maps]);
        Start >= Y andalso End =< Y + Z ->
            min_range_to_location(Start + D, End + D, Maps);
        Start >= Y ->
            lists:min([
                min_range_to_location(Start + D, Y + Z + D, Maps),
                min_range_to_location(Y + Z, End, [Map | Maps])
            ]);
        End =< Y + Z ->
            lists:min([
                min_range_to_location(Start, Y, [Map | Maps]),
                min_range_to_location(Y + D, End + D, Maps)
            ]);
        true ->
            lists:min([
                min_range_to_location(Start, Y, [Map | Maps]),
                min_range_to_location(Y + D, Y + Z + D, Maps),
                min_range_to_location(Y + Z, End, [Map | Maps])
            ])
    end.

pairs([X | [Y | Rest]]) ->
    [{X, Y} | pairs(Rest)];
pairs([]) ->
    [].

start() ->
    #data{seeds = Seeds, maps = [[] | Maps]} = parse_input(),

    % Part 1
    F = fun(S) -> to_location(S, Maps) end,
    io:fwrite("~p\n", [lists:min(lists:map(F, Seeds))]),

    % Part 2
    G = fun({S, L}) -> min_range_to_location(S, S + L, Maps) end,
    io:fwrite("~p\n", [lists:min(lists:map(G, pairs(Seeds)))]).
