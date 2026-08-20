# Grandma's Bingo Night

A 2D Godot 4 game. Nan remembers she has bingo tonight, so she legs it round the market
tents to tick off her grocery list before the shutters come down, then plays out the
evening at the hall.

Real assets were used for this projects made by Tina Shingrani as well as, free CC0 art from Kenney, plus sound and a
proper font. See CREDITS.md.

## The flow

MainMenu (your start page, click PLAY) -> intro video -> Intro cards -> Map

On the map, arrow keys walk Nan, space goes into whatever she is standing in front of,
and Tab opens the grocery checklist. Clicking a stall you can see still works and walks
her over to it. Where she is standing is kept in `Game.map_x`, so coming back from a
minigame puts her back at that stall rather than at the gate. -> (Chilli / Drinks / Flies in any order) -> Map -> BingoHall ->
Cocktails -> Bingo -> Ending

The shop timer only runs during the market half. It lives in `Game.shop_time_left`, so it
keeps counting across scene changes, which makes the three tents feel like one shopping
trip rather than three separate games. Mistakes cost seconds instead of ending the run.

## What is in the box

```
project.godot          settings, autoloads, 1280x720
art/                   your drawings, cut out and resized
art/ui/                Kenney CC0 panels, chips and boxes
art/hall.png           the bingo hall, built from Kenney building tiles
audio/                 Kenney CC0 sound effects
fonts/                 Kenney Future and Kenney Future Narrow
scenes/                one .tscn per scene, each just a root node with a script
scripts/
  Game.gd              autoload: shop timer, grocery list, score, scene changes
  Art.gd               loads and draws PNGs, nine slices panels, holds the font
  Sfx.gd               autoload: small pool of audio players, Sfx.play("click")
  Hud.gd               shared HUD built in code
  Map.gd               the market, walk between tents and click one to enter
  ChilliGame.gd        Nan follows the mouse, catch falling chillies in her arms
  DrinkGame.gd         hold to pour, stop when the drink reaches the line
  FlyGame.gd           swat fruit flies off the lemons with the racket
  CocktailGame.gd      mix drinks from the shopping: click chilli, lemon and shots
  BingoGame.gd         the card, called numbers, mark them before the next call
  Cutscene.gd          plays your intro video, skips itself if there is no file
  Intro / BingoHall    story cards
  Ending / ShopsClosed win and fail screens
CREDITS.md                  what came from where, and the licences
```

## The free assets, and why each one is there


| Was drawn in code | Is now |
|---|---|
| Purple box labelled BINGO HALL | `art/hall.png`, built from Kenney's building tiles with a signboard baked on |
| Bingo card squares and backing | Kenney UI panels, nine sliced, with poker chips as the daubers |
| White disc over the telly | a white chip from the Boardgame Pack |
| Timer bar and its background | Kenney panels as NinePatchRects, green until the last quarter then red |
| Label backgrounds and plaques | Kenney panels, tinted dark so white text reads on them |
| Level readout at the drinks stand | Kenney panels, yellow for the level she asked for, red for what you have poured |
| Godot's default font | Kenney Future Narrow for UI, Kenney Future for the big numbers |
| Silence | Kenney interface and boardgame sounds on every catch, pour, swat, mistake and call |


Nine slicing is the bit worth knowing about. A Kenney panel is 100x100 with rounded
corners, so stretching it to 520x40 would smear the corners. `Art.nine()` cuts it into
nine pieces and stretches only the middles, which is why the panels look right at any
size. The HUD uses Godot's built in `NinePatchRect` for the same reason.

## How my art got used

| Your drawing | Became | Used in |
|---|---|---|
| Landscape with hills | `bg_market.png` | menu, intro, map, chilli stand |
| Fruit stall with the girl | `tent_fruit.png` | map |
| Drink products stall | `tent_drinks.png` | map |
| Ice and Spice tent | `tent_chilli.png` | map, chilli stand |
| Start page with PLAY | `bg_start.png` | the first screen, the button is a hotspot over the painted one |
| Basket | `basket.png` | catches the chillies at the spice stand |
| Grandma, walking with her drink | `grandma_walk.png` | menu, intro, map, chilli stand, hall, win screen |
| Grandma, furious | `grandma_angry.png` | shops closed screen |
| PLAY bubble | `btn_play.png` | main menu, grows on hover |
| Flaming reload | `icon_retry.png` | both end screens, grows on hover |
| Biscuit | `cookie.png` | menu, last intro card, over a finished stall, win screen |
| Red anger mark | `anger.png` | pops up whenever you drop, spill or miss |
| Black haired woman | `vendor.png` | spare, she is the stall keeper not Nan |
| Three flies | `fly1/2/3.png` | fruit stand, cycled for a wing flap |
| Pink swatter | `swatter.png` | fruit stand cursor |
| Six chillies | `chilli_red1-4`, `chilli_green1-2` | falling chillies, picked at random |
| Crate of lemons | `bg_lemons.png` | fruit stand background |
| Bar with bottles | `bg_bar.png` | drinks stand, hall, cocktails |
| Empty glass | `glass.png` | drinks stand, cocktails |
| Six liquid levels | `fill0-5.png` | the fill levels |
| Hand with bottle, idle and pouring | `bottle_idle/pour.png` | drinks stand, cocktails |
| Bingo hall with the telly | `bg_bingo.png` | bingo game |
| Bingo hall with WIN | `bg_win.png` | winning ending |
| THE END | `bg_end.png` | losing ending |
| Plain fruit stall | `stall_fruit_plain.png` | spare, not used yet |

## Tuning

| What | Where | Value |
|---|---|---|
| Total shopping time | `Game.gd`, `SHOP_TIME` | 150 s |
| How far apart the stalls are | `Map.gd`, `WORLD_W` and the `x` in `stalls` | 2800 wide world |
| How fast Nan walks | `Map.gd`, `walk_speed` | 320 |
| How close she must stand to enter | `Map.gd`, `REACH` | 190 px |
| Chillies needed | `ChilliGame.gd`, `TARGET` | 12 |
| Catch area on Nan | `ChilliGame.gd`, `CATCH_TOP`, `CATCH_W`, `CATCH_H` | chest height |
| Glasses to pour | `DrinkGame.gd`, `CUPS_NEEDED` | 3 |
| Pour speed | `DrinkGame.gd`, `_pour_rate()` | faster each glass |
| Where the line can land | `DrinkGame.gd`, `randi_range(2, LEVELS)` | levels 2 to 6 |
| Flies and racket size | `FlyGame.gd`, `FLY_COUNT`, `HIT_RADIUS` | 9, 62 px |
| Bingo call speed | `BingoGame.gd`, `CALL_INTERVAL` | 2.4 s |
| Orders at the hall | `CocktailGame.gd`, `ORDERS`, `ROUND_TIME` | 5 orders, 80 s |
| PLAY and retry buttons | `PLAY_CENTRE`, `RETRY_CENTRE`, and the `_H` next to them | position and size |


---



