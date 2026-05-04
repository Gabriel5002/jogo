% ==========================================================
% JOGO DA VELHA - VERSÃO AVANÇADA (IA LÓGICA)
% ==========================================================

% =========================
% 1. FATOS
% =========================

jogada(1,1,x).
jogada(1,2,x).
jogada(1,3,x).

jogada(2,1,o).
jogada(2,2,o).

jogada(3,1,x).

% =========================
% 2. REGRAS DE VITÓRIA
% =========================

linha(1). linha(2). linha(3).
coluna(1). coluna(2). coluna(3).

% combinações vencedoras
vitoria(J) :- jogada(1,1,J), jogada(1,2,J), jogada(1,3,J).
vitoria(J) :- jogada(2,1,J), jogada(2,2,J), jogada(2,3,J).
vitoria(J) :- jogada(3,1,J), jogada(3,2,J), jogada(3,3,J).

vitoria(J) :- jogada(1,1,J), jogada(2,1,J), jogada(3,1,J).
vitoria(J) :- jogada(1,2,J), jogada(2,2,J), jogada(3,2,J).
vitoria(J) :- jogada(1,3,J), jogada(2,3,J), jogada(3,3,J).

vitoria(J) :- jogada(1,1,J), jogada(2,2,J), jogada(3,3,J).
vitoria(J) :- jogada(1,3,J), jogada(2,2,J), jogada(3,1,J).

% =========================
% 3. TABULEIRO
% =========================

ocupado(L,C) :- jogada(L,C,_).

livre(L,C) :-
    linha(L), coluna(C),
    \+ ocupado(L,C).

% =========================
% 4. LÓGICA DE JOGO
% =========================

jogador(x).
jogador(o).

% próximo jogador
conta(J,N) :-
    findall(_, jogada(_,_,J), L),
    length(L,N).

proximo(x) :-
    conta(x,NX), conta(o,NO),
    NX =:= NO.

proximo(o) :-
    conta(x,NX), conta(o,NO),
    NX > NO.

% =========================
% 5. INTELIGÊNCIA (IA)
% =========================

% quase vitória (2 peças + 1 livre)
quase_vitoria(J,L,C) :-
    livre(L,C),
    assert(jogada(L,C,J)),
    vitoria(J),
    retract(jogada(L,C,J)).

% bloquear adversário
bloquear(J,L,C) :-
    (J = x -> O = o ; O = x),
    quase_vitoria(O,L,C).

% melhor jogada (prioridade lógica)
melhor_jogada(J,L,C) :-
    quase_vitoria(J,L,C), !.        % ganhar

melhor_jogada(J,L,C) :-
    bloquear(J,L,C), !.            % bloquear

melhor_jogada(_,2,2) :-            % centro
    livre(2,2), !.

melhor_jogada(_,L,C) :-            % qualquer livre
    livre(L,C).

% =========================
% 6. ESTADO DO JOGO
% =========================

vencedor(J) :- vitoria(J).

empate :-
    \+ vencedor(x),
    \+ vencedor(o),
    \+ livre(_, _).

% =========================
% 7. CONSULTAS
% =========================

% todas livres
todas_livres(L) :-
    findall((X,Y), livre(X,Y), L).

% jogadas possíveis do próximo jogador
jogadas_proximas(L) :-
    proximo(J),
    findall((X,Y,J), livre(X,Y), L).

% sugestão de jogada inteligente
sugestao(L,C) :-
    proximo(J),
    melhor_jogada(J,L,C).