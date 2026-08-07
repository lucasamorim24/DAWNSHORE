# Dawnshore — Kickoff / Handoff

> Documento de continuidade. Abra num novo chat deste projeto para saber onde
> paramos e retomar o trabalho sem perder contexto.
> Última atualização: 2026-08-06.

---

## 1. O que é o projeto

**Dawnshore** — jogo em **GameMaker (GML)**. Estamos na fase de **construir as
mecânicas e a lógica**, ainda **sem assets**: tudo é desenhado com primitivas
(losangos, cubo, retângulos). A pixel art / sprites / animações virão depois e
vão **substituir só a renderização** — a lógica e o estado devem permanecer.

Tabuleiro isométrico **4x4**, quadrantes rotulados estilo batalha naval:
colunas `A–D`, linhas `1–4` (`A1` … `D4`).

**Resolução base (ajustada em 2026-08-07):** pixel art **320×180** (16:9, estilo
Papers Please), que sobe por **escala inteira** para telas grandes (×4=1280×720,
×5=1600×900, ×6=1920×1080). Era 480×270; baixamos para **320×180** para o tabuleiro
(≈128px, arte de tiles 32px) ocupar mais da tela — base menor = arte maior, sem
esticar sprite (o que quebraria o pixel-perfect). Dial: só `GAME_WIDTH/GAME_HEIGHT`
(16:9). **Pixel-perfect:** interpolação desligada nas opções
(`option_windows_interpolate_pixels: false`) + `gpu_set_tex_filter(false)` +
`obj_display` trava na maior escala **inteira** que cabe no monitor — escala
fracionária é o que deixa o pixel "estourado" (uns pixels maiores que outros). Fonte de verdade em `scr_display_config` (macros
`GAME_WIDTH`, `GAME_HEIGHT`, `GAME_SCALE_INIT`) e o controlador `obj_display`.
Intenção de **mobile num segundo momento** — a troca mora quase toda nesses dois
lugares. HUD/menus vivem na **camada GUI** (mesma resolução base, 1:1 com os
pixels do jogo). Fonte de texto ainda é a padrão (só ASCII) — daí "MARE" sem
acento; uma fonte de pixel art (com acento) entra junto com os demais assets.

**Layout (referência estilo diorama/Stardew):** duas **faixas reservadas** de
largura total (topo e base) e a **zona de jogo central** no meio, com margens
laterais iguais (macros em `scr_display_config`; `game_play_zone()` é a fonte de
verdade). A faixa do **topo é a HUD** com três espaços: canto superior esquerdo,
centro (marcador **Maré**) e canto superior direito (info do personagem etc.) —
**não** existe painel vertical na direita. A **base** fica reservada (a definir).
O tabuleiro é um **diorama compacto centralizado** nessa zona (tiles com face de
topo **32×16**, casando 1:1 com o tileset isométrico baixado).
`DEBUG_LAYOUT` liga guias visuais das faixas enquanto o conteúdo real não existe.

---

## 2. Diretriz permanente (IMPORTANTE — já está na memória)

**Tudo que for construído deve ser escalonável, reaproveitável e otimizado —
nunca descartável.** Regras práticas que seguimos:

- **Estado em estruturas de dados**, não dentro do Draw (posição em grid, não
  pixel; propriedades em structs).
- **Lógica fora do Draw** — vai em Step / scripts. O Draw só lê estado e pinta.
- **Fonte de verdade única** — uma regra vive em um lugar só, consumida por
  render e por lógica (evitar duplicação).
- **Ganchos reservados** para features futuras.

Memória relacionada: `build-for-scalability`. **Consuma a memória do projeto
antes de continuar.**

---

## 3. Mapa dos arquivos

```
scripts/
  scr_display_config   -> FONTE DE VERDADE do display E do layout:
                          resolucao (GAME_WIDTH=320, GAME_HEIGHT=180, GAME_SCALE_INIT=5);
                          faixas reservadas da HUD (HUD_TOP_HEIGHT=40,
                          HUD_BOTTOM_HEIGHT=40, HUD_SIDE_MARGIN=12) -> topo e base
                          de largura total + margens laterais iguais;
                          DEBUG_LAYOUT (guias dev); game_play_zone() -> retangulo
                          central onde o tabuleiro vive
  scr_board_config     -> macros: BOARD_COLUMNS=4, BOARD_ROWS=4;
                          FACE DE TOPO do losango TILE_WIDTH=32, TILE_HEIGHT=16
                          (casa 1:1 o tileset iso 32x32); TILE_SPRITE_SIZE=32,
                          TILE_BLOCK_HEIGHT=8 (saia do bloco / elevacao futura)
  scr_grid_to_iso      -> grid_to_iso(col,row,ox,oy)  e  iso_to_grid(sx,sy,ox,oy)
                          (conversões grade <-> tela isométrica; inversas)

objects/
  obj_display          (persistente; 1º na ordem de criação)
    Create_0   -> pixel-perfect: gpu_set_tex_filter(false) + GUI na base +
                  janela na MAIOR escala INTEIRA que cabe no monitor (evita o
                  "estourado" da escala fracionária), centralizada.
    Draw_64    -> (Draw GUI) guias dev das faixas reservadas + contorno da zona de
                  jogo. Só quando DEBUG_LAYOUT (hoje false). Andaime visual.
  obj_board            (GERENTE da grade; nao desenha - nao tem mais evento Draw)
    Create_0   -> board_origin_x/y centralizam o tabuleiro na game_play_zone()
                  (zona central que sobra após as faixas da HUD); altura derivada
                  do grid; column_letters; CRIA as 16 instancias de obj_quadrante e
                  guarda as referencias na matriz `quadrantes[row][col]`; hovered_*
                  (init -1)
    Step_0     -> calcula o quadrante sob o mouse (hovered_column/row). LÓGICA.
  obj_quadrante        (UMA instancia por casa; substituiu os structs anonimos)
    Create_0   -> defaults da casa: column/row/label, iso_x/iso_y (= x/y, ancora no
                  vertice de topo), esforco/resistencia/visibilidade (0, RESERVADAS),
                  hovered, board, depth. O obj_board sobrescreve os reais no create.
    Step_0     -> deriva o proprio `hovered` da fonte de verdade do board
                  (hovered_column/row). LOGICA/reacoes futuras da casa.
    Draw_0     -> desenha o proprio losango + rotulo; verde sob o mouse. SO RENDER.
                  Vira draw_self() quando o sprite isometrico entrar.
  obj_mare
    Create_0   -> estado do cronometro: mare_duration_seconds (300),
                  mare_time_left, mare_cycles, mare_margin_top. LOGICA/ESTADO.
    Step_0     -> regride mare_time_left por delta_time; ao zerar, incrementa
                  mare_cycles e reinicia o ciclo. GANCHO da re-randomizacao. LOGICA.
    Draw_64    -> (Draw GUI) barra compacta de 1 linha "MARE  M:SS" no topo-centro,
                  com fundinho pra contraste. SO RENDER.
  obj_player
    Create_0   -> estado (column_index/row_index/label), cores do cubo,
                  place_on_tile(), get_reachable_tiles(), is_yellow_neighbor(),
                  estado + geometria do menu (overlay central, coords de GUI)
    Mouse_53   -> (Global Left Pressed) decide o clique: menu aberto interage com
                  ele (hit-test em coords de GUI); senão quadrante alcançável abre o
                  menu e os demais movem direto
    Draw_0     -> desenha o cubo isométrico (3 faces + contorno + rótulo) e o
                  destaque amarelo da cruz. SÓ RENDER.
    Draw_64    -> (Draw GUI) menu Movimentar/Pescar como overlay central. SÓ RENDER.
```

---

## 4. Estado guardado (sobrevive à troca por assets)

**Tabuleiro** — `obj_board.quadrantes[row][col]` guarda a **instância de
`obj_quadrante`** daquela casa (antes era um struct anônimo; a API de leitura é a
mesma, ex.: `board.quadrantes[r][c].label`). Cada casa é um objeto, com estas
variáveis de instância:
```
column_index, row_index,
label,                    // "A1" … "D4"
iso_x, iso_y,             // = x/y da instância; vértice de topo do losango na tela
hovered,                  // derivado no Step do board (hovered_column/row)
board,                    // referência ao obj_board (origem do grid + hover)
depth,                    // ordem isométrica (frente por cima); sempre atrás do player
esforco: 0,               // \
resistencia: 0,           //  > RESERVADOS: serão populados depois pela
visibilidade: 0           // /  re-randomização via "Maré" (etapa futura)
```
Ser objeto (e não struct) é de propósito: além de receber o **sprite isométrico**,
cada casa tem eventos próprios (Step/Alarm/Mouse/colisão) e pode ser referenciada/
alvejada por outros objetos e pela mecânica da Maré. A Maré vai iterar as instâncias
de `obj_quadrante` (ou a matriz) e popular `esforco/resistencia/visibilidade`.

**Jogador** — `obj_player`: `column_index`, `row_index`, `label` (posição em
grade, não pixel). `place_on_tile(col,row)` é o único ponto que altera a posição.

**Cruz / alcance** — `get_reachable_tiles()` é a **fonte de verdade** dos
quadrantes alcançáveis (hoje: 4 vizinhos ortogonais dentro do tabuleiro).
Consumida pelo destaque amarelo (Draw) e pela lógica de clique (Mouse). Mudar
a regra de alcance aqui reflete em todo lugar.

**Janela de ação** — `menu_open`, `menu_target_col/row`, geometria e
`menu_button_rect(index)`. Agora é um **overlay central na camada GUI**
(coordenadas de tela); o clique é testado com o mouse convertido para GUI
(`device_mouse_*_to_gui`).

---

## 5. O que já está implementado

- **Resolução base 320×180** (pixel art, 16:9) com escala inteira via `obj_display`
  + `scr_display_config`. Tabuleiro centralizado na zona de jogo. HUD/menus na
  camada GUI. Faixas HUD 28/28, margem lateral 8.
- **Render dos tiles**: `obj_quadrante` sabe desenhar de dois jeitos — se tiver
  sprite, via `draw_sprite` com âncora no vértice de topo (offset no Draw, origem do
  sprite pode ser (0,0)); **sem sprite, cai no losango-primitiva com o rótulo A1–D4**.
  Hover verde por cima nos dois. HOJE o `obj_quadrante` está **sem sprite** (spriteId
  null) → mostra os losangos rotulados. A arte de água foi destacada de propósito
  (não ficou boa ainda); ver pendências.
- **Água animada** (`spr_water`, PRONTA mas DESTACADA): sprite de 10 quadros (tiles
  104–113, 8 fps) já montado no projeto, hoje **não atribuído** ao `obj_quadrante`.
  A dessincronização já está codada no Create (`image_index` aleatório + `image_speed`
  ±15%, com `randomize()` no boot do `obj_display`) e ativa sozinha para qualquer
  sprite animado (>1 quadro). Para religar a água: `obj_quadrante.spriteId = spr_water`.
- Grid isométrico 4x4 estático com rótulos A1–D4.
- **Quadrantes como objetos** (`obj_quadrante`): cada casa é uma instância própria
  (estado + eventos), criada pelo `obj_board`, pronta para receber o sprite
  isométrico e interagir mecanicamente com outros objetos / a Maré. Cada casa se
  desenha e deriva seu próprio hover; o `obj_board` virou o gerente da grade.
- Movimento do jogador clicando em quadrantes.
- Cubo isométrico ocupando 1 quadrante, com rótulo na face de topo.
- Destaque da **cruz** (quadrantes alcançáveis) em amarelo.
- **Hover**: quadrante sob o mouse fica **verde**.
- **Transparência do cubo**: quando o mouse passa por um quadrante que o corpo
  do cubo encobre na tela (os "de trás"), o cubo fica translúcido (alpha 0.4).
- **Menu de ação** (overlay central na GUI): clicar num quadrante alcançável abre
  um painel perguntando **Movimentar** ou **Pescar** (seleção por clique esquerdo;
  botão sob o mouse realçado). Clicar fora fecha.
- **Marcador "Maré"** (`obj_mare`): cronômetro regressivo de 5 min no topo-centro
  (barra compacta de 1 linha na GUI), rodando em loop. Ao zerar, é o gancho da
  re-randomização (hoje só reinicia e conta `mare_cycles`).

---

## 6. Pendências / próximos passos

- [ ] **Pescar**: hoje é *placeholder* (só fecha a janela). Definir a mecânica
      de pesca e plugar em `obj_player/Mouse_53.gml` (ramo do botão Pescar).
- [ ] **"Maré" (re-randomização)**: o cronômetro já existe em `obj_mare` e vira
      a cada 5 min. Falta o efeito: popular `esforco/resistencia/visibilidade` de
      cada quadrante dentro de intervalos pré-definidos. Lugar natural: um script
      chamado do gancho no `obj_mare/Step_0.gml` (onde `mare_cycles++`).
- [ ] **Assets do tabuleiro**: tileset isométrico em `D:\GAME DEV\isometric tileset`
      (115 tiles 32×32 + `spritesheet.png` 352×352, grade 11×11). Board dimensionado
      1:1 (face 32×16, bloco 8px) e o render por sprite **já ligado**. HOJE todas as
      casas usam `spr_water` (água animada, tiles 104–113). Referência do tileset:
      tile 103 = água funda (estática); 104–113 = água animada. Falta: importar os
      demais terrenos (grama, terra etc.) e atribuir **variedade por casa** — mapa de
      terreno fixo ou **sorteado pela Maré** (definir `sprite_index` de cada
      `obj_quadrante`, provavelmente no gancho do `obj_mare`). Ao dar sprite animado a
      uma casa, a dessincronização já acontece sozinha (Create). Cubo do jogador e
      marcador seguem o mesmo caminho depois.
- [ ] **Fonte de pixel art**: hoje o texto usa a fonte padrão (só ASCII), por isso
      "MARE" sem acento. Criar uma fonte (com acentos) e trocar os `draw_text` —
      "Maré" volta a ter acento. Entra junto com os demais assets.
- [ ] **Escala com aspecto travado / fullscreen / mobile**: `obj_display` hoje só
      define a janela inicial (base×escala) e o GUI. Falta tratar resize/fullscreen
      mantendo 16:9 (letterbox) e a adaptação pra mobile — tudo concentrado nesse
      controlador.
- [ ] **Otimização futura (se escalar)**: `get_reachable_tiles()` recria a lista
      por frame no Draw — irrelevante para 4 tiles. Se a área alcançável crescer
      muito, cachear a lista e recalcular só dentro de `place_on_tile()`.

---

## 7. Estado do Git

Branch: `master` (branch principal). Trabalho da última sessão **ainda não
commitado**. Mensagem de commit sugerida:

**Título:** `Hover, janela Movimentar/Pescar e refatoracao de estado`

**Corpo:**
```
Mecanicas:
- Quadrante sob o mouse destacado em verde
- Cubo do jogador fica translucido quando o mouse passa por um
  quadrante que ele encobre na tela
- Clique em quadrante alcancavel abre janela Movimentar/Pescar a
  direita do tabuleiro; demais quadrantes movem direto
  (Pescar ainda e placeholder)

Arquitetura (estado separado da renderizacao):
- Deteccao de hover movida do Draw para novo evento Step do board
- get_reachable_tiles() como fonte de verdade unica da cruz,
  consumida pelo destaque (Draw) e pela logica de clique (Mouse)
```
