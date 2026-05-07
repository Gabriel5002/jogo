% ==========================================================
% JOGO DA VELHA - VERSÃO MELHORADA
% ==========================================================

% =========================
% 1. FATOS INICIAIS
% =========================

jogada(1,1,x).
jogada(1,2,x).
jogada(1,3,x).

jogada(2,1,o).
jogada(2,2,o).

jogada(3,1,x).

% =========================
% 2. ESTRUTURA DO TABULEIRO
% =========================

linha(1). linha(2). linha(3).
coluna(1). coluna(2). coluna(3).

% todas posições possíveis
pos(L,C) :- linha(L), coluna(C).

% =========================
% 3. OCUPAÇÃO
% =========================

ocupado(L,C) :- jogada(L,C,_).

livre(L,C) :- pos(L,C), \+ ocupado(L,C).

% =========================
% 4. COMBINAÇÕES VENCEDORAS
% =========================

combinacao([
    (1,1),(1,2),(1,3)
]).
combinacao([
    (2,1),(2,2),(2,3)
]).
combinacao([
    (3,1),(3,2),(3,3)
]).
combinacao([
    (1,1),(2,1),(3,1)
]).
combinacao([
    (1,2),(2,2),(3,2)
]).
combinacao([
    (1,3),(2,3),(3,3)
]).
combinacao([
    (1,1),(2,2),(3,3)
]).
combinacao([
    (1,3),(2,2),(3,1)
]).

% verifica se todas posições pertencem ao jogador
todas_do_jogador([], _).
todas_do_jogador([(L,C)|T], J) :-
    jogada(L,C,J),
    todas_do_jogador(T, J).

% vitória genérica
vitoria(J) :-
    combinacao(Comb),
    todas_do_jogador(Comb, J).

% =========================
% 5. JOGADORES
% =========================

jogador(x).
jogador(o).

outro(x,o).
outro(o,x).

% =========================
% 6. PRÓXIMO JOGADOR
% =========================

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
% 7. IA (SEM ASSERT/RETRACT)
% =========================

% verifica vitória simulando jogada
vitoria_com_jogada(J,L,C) :-
    combinacao(Comb),
    member((L,C), Comb),
    conta_posicoes(Comb, J, L, C, 3).

% conta quantas posições seriam do jogador (incluindo jogada simulada)
conta_posicoes([], _, _, _, 0).
conta_posicoes([(L,C)|T], J, L1, C1, N) :-
    ( (L = L1, C = C1) ; jogada(L,C,J) ),
    conta_posicoes(T, J, L1, C1, N1),
    N is N1 + 1.
conta_posicoes([(L,C)|T], J, L1, C1, N) :-
    \+ ( (L = L1, C = C1) ; jogada(L,C,J) ),
    conta_posicoes(T, J, L1, C1, N).

% ganhar
ganhar(J,L,C) :-
    livre(L,C),
    vitoria_com_jogada(J,L,C).

% bloquear adversário
bloquear(J,L,C) :-
    outro(J,O),
    ganhar(O,L,C).

% melhor jogada
melhor_jogada(J,L,C) :-
    ganhar(J,L,C), !.

melhor_jogada(J,L,C) :-
    bloquear(J,L,C), !.

melhor_jogada(_,2,2) :-
    livre(2,2), !.

melhor_jogada(_,L,C) :-
    livre(L,C).

% =========================
% 8. ESTADO DO JOGO
% =========================

vencedor(J) :- vitoria(J).

empate :-
    \+ vencedor(x),
    \+ vencedor(o),
    \+ livre(_, _).

% =========================
% 9. CONSULTAS
% =========================

todas_livres(L) :-
    findall((X,Y), livre(X,Y), L).

jogadas_proximas(L) :-
    proximo(J),
    findall((X,Y,J), livre(X,Y), L).

sugestao(L,C) :-
    proximo(J),
    melhor_jogada(J,L,C).
