% ==========================================================
% RPG LÓGICO INFERNAL - PLANEJAMENTO OTIMIZADO
% ==========================================================

% =========================
% 1. ESTADO
% =========================

% estado(Posicao, Inventario, Derrotados, Vida, Custo)

estado_inicial(
    estado(vila, [], [], 12, 0)
).

% =========================
% 2. MAPA
% =========================

conectado(vila, floresta).
conectado(floresta, caverna).
conectado(caverna, ruinas).
conectado(ruinas, torre).
conectado(torre, dragao).

caminho(X,Y) :- conectado(X,Y).
caminho(X,Y) :- conectado(Y,X).

% =========================
% 3. ITENS
% =========================

local_item(espada, floresta).
local_item(escudo, vila).
local_item(chave, caverna).
local_item(cajado, torre).
local_item(armadura, ruinas).

% =========================
% 4. INIMIGOS
% =========================

inimigo(goblin, floresta, 5).
inimigo(troll, caverna, 9).
inimigo(espectro, ruinas, 13).
inimigo(dragao, dragao, 25).

% =========================
% 5. PODER
% =========================

poder([],1).
poder([espada|T],P) :- poder(T,P1), P is P1 + 6.
poder([escudo|T],P) :- poder(T,P1), P is P1 + 3.
poder([cajado|T],P) :- poder(T,P1), P is P1 + 7.
poder([armadura|T],P) :- poder(T,P1), P is P1 + 5.
poder([_|T],P) :- poder(T,P).

% =========================
% 6. AÇÕES COM CUSTO
% =========================

% mover custa 1
acao(
    mover(De,Para),
    estado(De,Inv,Der,V,C),
    estado(Para,Inv,Der,V,C1)
) :-
    caminho(De,Para),
    C1 is C + 1.

% pegar item custa 1
acao(
    pegar(Item),
    estado(Local,Inv,Der,V,C),
    estado(Local,[Item|Inv],Der,V,C1)
) :-
    local_item(Item, Local),
    \+ member(Item, Inv),
    C1 is C + 1.

% lutar custa vida e aumenta custo
acao(
    lutar(Inimigo),
    estado(Local,Inv,Der,V,C),
    estado(Local,Inv,[Inimigo|Der],V2,C1)
) :-
    inimigo(Inimigo, Local, Forca),
    \+ member(Inimigo, Der),
    poder(Inv, P),
    P + V >= Forca,
    V2 is V - 3,
    V2 > 0,
    C1 is C + 2.

% =========================
% 7. RESTRIÇÕES INFERNAIS
% =========================

% não pode lutar dragão sem chave
restricao(estado(_,Inv,_,_,_)) :-
    (member(dragao, Inv) -> member(chave, Inv) ; true).

% precisa de arma forte para dragão
arma_forte(Inv) :-
    member(espada, Inv);
    member(cajado, Inv).

% =========================
% 8. OBJETIVO
% =========================

objetivo(
    estado(dragao, Inv, Der, V, _)
) :-
    member(dragao, Der),
    member(chave, Inv),
    arma_forte(Inv),
    V > 0.

% =========================
% 9. PLANEJAMENTO COM PODA
% =========================

planejar(Estado, _, [], Estado) :-
    objetivo(Estado).

planejar(Estado, Visitados, [Acao|Plano], Final) :-
    acao(Acao, Estado, NovoEstado),
    NovoEstado = estado(_,_,_,V,_),
    V > 0, % poda por morte
    \+ member(NovoEstado, Visitados),
    restricao(NovoEstado),
    planejar(NovoEstado, [NovoEstado|Visitados], Plano, Final).

% =========================
% 10. MELHOR SOLUÇÃO (OTIMIZAÇÃO)
% =========================

resolver_melhor(PlanoMelhor) :-
    findall((Plano,Custo),
        (
            estado_inicial(E),
            planejar(E,[E],Plano,estado(_,_,_,_,Custo))
        ),
        Solucoes),
    melhor_plano(Solucoes, PlanoMelhor).

melhor_plano([(P,_)], P).
melhor_plano([(P1,C1),(P2,C2)|Resto], Melhor) :-
    (C1 =< C2 ->
        melhor_plano([(P1,C1)|Resto], Melhor)
    ;
        melhor_plano([(P2,C2)|Resto], Melhor)
    ).
    melhor_jogada(J,L,C).
