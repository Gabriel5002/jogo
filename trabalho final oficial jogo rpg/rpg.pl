% ==========================================================
% RPG LÓGICO INFERNAL - ENGINE PROFISSIONAL (SWISH)
% ==========================================================

:- use_module(library(lists)).

% ==========================================================
% 1. ESTADO
% ==========================================================
% estado(Posicao, Inventario, Derrotados, Vida, Custo)

estado_inicial(estado(vila, [], [], 12, 0)).

% ==========================================================
% 2. MAPA
% ==========================================================

conectado(vila, floresta).
conectado(floresta, caverna).
conectado(caverna, ruinas).
conectado(ruinas, torre).
conectado(torre, dragao).

% atalhos (aumenta complexidade)
conectado(floresta, ruinas).
conectado(caverna, torre).

caminho(X,Y) :- conectado(X,Y).
caminho(X,Y) :- conectado(Y,X).

% ==========================================================
% 3. ITENS
% ==========================================================

local_item(espada, floresta).
local_item(escudo, vila).
local_item(chave, caverna).
local_item(cajado, torre).
local_item(armadura, ruinas).

% ==========================================================
% 4. INIMIGOS
% ==========================================================

inimigo(goblin, floresta, 5).
inimigo(troll, caverna, 9).
inimigo(espectro, ruinas, 13).
inimigo(guardiao, torre, 17).
inimigo(dragao, dragao, 25).

% ==========================================================
% 5. PODER (OTIMIZADO)
% ==========================================================

valor_item(espada,6).
valor_item(escudo,3).
valor_item(cajado,7).
valor_item(armadura,5).

poder(Inv,P) :-
    findall(V,
        (member(I,Inv), valor_item(I,V)),
        Lista),
    sum_list(Lista,Soma),
    P is Soma + 1.

% bônus estratégico
bonus(Inv,5) :-
    member(espada,Inv),
    member(armadura,Inv), !.
bonus(_,0).

% ==========================================================
% 6. AÇÕES
% ==========================================================

% mover
acao(mover(De,Para),
     estado(De,Inv,Der,V,C),
     estado(Para,Inv,Der,V,C1)) :-
    caminho(De,Para),
    C1 is C + 1.

% pegar item
acao(pegar(Item),
     estado(Local,Inv,Der,V,C),
     estado(Local,[Item|Inv],Der,V,C1)) :-
    local_item(Item, Local),
    \+ member(Item, Inv),
    C1 is C + 1.

% lutar
acao(lutar(Inimigo),
     estado(Local,Inv,Der,V,C),
     estado(Local,Inv,[Inimigo|Der],V2,C1)) :-
    inimigo(Inimigo, Local, Forca),
    \+ member(Inimigo, Der),
    poder(Inv,P),
    bonus(Inv,B),
    P + B + V >= Forca,
    V2 is V - 3,
    V2 > 0,
    C1 is C + 2.

% descansar (melhora estratégia)
acao(descansar,
     estado(Local,Inv,Der,V,C),
     estado(Local,Inv,Der,V2,C1)) :-
    V < 12,
    V2 is V + 2,
    C1 is C + 2.

% ==========================================================
% 7. RESTRIÇÕES (MAIS SEGURAS)
% ==========================================================

% precisa chave para dragão
restricao(estado(_,Inv,Der,_,_)) :-
    (member(dragao, Der) -> member(chave, Inv) ; true).

% limite de inventário (evita explosão)
restricao(estado(_,Inv,_,_,_)) :-
    length(Inv,N),
    N =< 5.

% ==========================================================
% 8. OBJETIVO
% ==========================================================

objetivo(estado(dragao,Inv,Der,V,_)) :-
    member(dragao, Der),
    member(chave, Inv),
    arma_forte(Inv),
    V > 0.

arma_forte(Inv) :-
    member(espada,Inv);
    member(cajado,Inv).

% ==========================================================
% 9. PLANEJAMENTO (COM LIMITE)
% ==========================================================

% limite de profundidade (ESSENCIAL no SWISH)
limite(15).

planejar(Estado, _, [], Estado, _) :-
    objetivo(Estado).

planejar(Estado, Visitados, [Acao|Plano], Final, Prof) :-
    limite(L),
    Prof < L,
    acao(Acao, Estado, NovoEstado),
    NovoEstado = estado(_,_,_,V,_),
    V > 0,
    \+ member(NovoEstado, Visitados),
    restricao(NovoEstado),
    P1 is Prof + 1,
    planejar(NovoEstado, [NovoEstado|Visitados], Plano, Final, P1).

% ==========================================================
% 10. RESOLVER (VERSÃO SEGURA)
% ==========================================================

resolver(Plano) :-
    estado_inicial(E),
    planejar(E,[E],Plano,_,0).

% ==========================================================
% 11. MELHOR SOLUÇÃO (CONTROLADA)
% ==========================================================

resolver_melhor(PlanoMelhor) :-
    findall((Plano,Custo),
        (
            estado_inicial(E),
            planejar(E,[E],Plano,estado(_,_,_,_,Custo),0)
        ),
        Solucoes),
    Solucoes \= [],
    melhor_plano(Solucoes, PlanoMelhor).

melhor_plano([(P,_)], P).
melhor_plano([(P1,C1),(P2,C2)|R], Melhor) :-
    (C1 =< C2 ->
        melhor_plano([(P1,C1)|R], Melhor)
    ;
        melhor_plano([(P2,C2)|R], Melhor)
    ).