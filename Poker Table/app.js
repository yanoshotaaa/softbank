// --- 設定値 ---
const PLAYER_NUM = 6;
const START_STACK = 300;
const SB = 1;
const BB = 3;
const ANTE = 0;
const POSITIONS = ["BTN", "SB", "BB", "UTG", "HJ", "CO"];

let state = null;
let dealerPosition = 0; // ディーラーボタンの位置（0-5）
let handNumber = 1; // ハンド番号
if (!window.allHistory) window.allHistory = [];
let startStacks = Array(PLAYER_NUM).fill(START_STACK - ANTE);

// --- ユーティリティ ---
function shuffle(arr) {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
}
function sleep(ms) { return new Promise(res => setTimeout(res, ms)); }
function cardSuit(card) {
  if (!card) return '';
  if (card.endsWith("♥")) return "suit-heart";
  if (card.endsWith("♦")) return "suit-diamond";
  if (card.endsWith("♠")) return "suit-spade";
  if (card.endsWith("♣")) return "suit-club";
  return '';
}

// ポジション割り当て関数
function assignPositions(dealerPos) {
  const positions = Array(PLAYER_NUM);
  
  // ディーラーボタンから時計回りでポジション名を割り当て
  // BTN -> SB -> BB -> UTG -> HJ -> CO
  for (let i = 0; i < PLAYER_NUM; i++) {
    const seatIndex = (dealerPos + i) % PLAYER_NUM;
    positions[seatIndex] = POSITIONS[i];
  }
  
  return positions;
}

// チップ位置計算関数
function calculateChipPosition(seatIndex, tableWidth, tableHeight) {
  const N = PLAYER_NUM;
  const cx = tableWidth / 2, cy = tableHeight / 2;
  
  // テーブル楕円のサイズ
  const tableRx = tableWidth * 0.25, tableRy = tableHeight * 0.28;
  
  // 座席配置用の楕円サイズ
  const seatW = Math.max(tableWidth * 0.13, 90), seatH = Math.max(tableHeight * 0.16, 70);
  const seatRx = tableRx + seatW * 1.2; // 座席より少し内側
  const seatRy = tableRy + seatH * 1.0;

  // プレイヤー0（あなた）が手前（下側）に来るように調整
  const adjustedIndex = (seatIndex - 0 + N) % N;
  const angle = (Math.PI * 2 * adjustedIndex / N) + Math.PI / 2;
  
  // チップ位置を楕円の内側に配置
  const chipX = cx + seatRx * Math.cos(angle) - 25; // チップサイズの半分
  const chipY = cy + seatRy * Math.sin(angle) - 25;
  
  return { x: chipX, y: chipY };
}

// ▼▼▼ 楕円テーブル描画（チップ表示機能追加） ▼▼▼
function renderEllipseTable(players, boardCards = [], actionLogs = [], currentPlayerIndex = -1) {
  const table = document.createElement("div");
  table.className = "table-ellipse";

  // サイズをウィンドウ基準で
  const w = Math.min(window.innerWidth * (window.innerWidth < 800 ? 0.96 : 0.7), 1200);
  const h = Math.max(w * (window.innerWidth < 800 ? 0.6 : 0.58), 280);

  table.style.width = w + "px";
  table.style.height = h + "px";

  const N = players.length;
  const cx = w / 2, cy = h / 2;
  
  // テーブル楕円のサイズ（内側の実際のテーブル）
  const tableRx = w * 0.25, tableRy = h * 0.28;
  
  // 座席のサイズ
  const seatW = Math.max(w * 0.13, 90), seatH = Math.max(h * 0.16, 70);
  
  // 座席配置用の楕円サイズ（テーブルの外側）
  const seatRx = tableRx + seatW * 2; // テーブルから座席幅分離れた位置
  const seatRy = tableRy + seatH * 1.5; // テーブルから座席高さ分離れた位置

  // ディーラーボタンの表示情報を追加
  const dealerButtonInfo = document.createElement("div");
  dealerButtonInfo.style.position = "absolute";
  dealerButtonInfo.style.top = "-50px";
  dealerButtonInfo.style.right = "10px";
  dealerButtonInfo.style.background = "#1976d2";
  dealerButtonInfo.style.color = "white";
  dealerButtonInfo.style.padding = "8px 12px";
  dealerButtonInfo.style.borderRadius = "8px";
  dealerButtonInfo.style.fontSize = "0.9em";
  dealerButtonInfo.style.fontWeight = "bold";
  dealerButtonInfo.style.zIndex = "20";
  dealerButtonInfo.innerHTML = `Hand #${handNumber}<br>Dealer: ${players[dealerPosition]?.name || 'Player'}`;
  table.appendChild(dealerButtonInfo);

  // 直近アクション（全体のactionLogsから各プレイヤーごと最新だけ抽出）
  let latestActions = {};
  if (actionLogs && actionLogs.length) {
    for (let i = actionLogs.length - 1; i >= 0; i--) {
      const log = actionLogs[i];
      if (!(log.player in latestActions)) {
        latestActions[log.player] = log;
      }
    }
  }

  for (let i = 0; i < N; i++) {
    // プレイヤー0（あなた）が手前（下側）に来るように調整
    const adjustedIndex = (i - 0 + N) % N;
    const angle = (Math.PI * 2 * adjustedIndex / N) + Math.PI / 2;
    
    // 座席を楕円の外側に配置
    const x = cx + seatRx * Math.cos(angle) - seatW / 2;
    const y = cy + seatRy * Math.sin(angle) - seatH / 2;
    
    const p = players[i];
    const seat = document.createElement("div");
    
    // 座席のクラス設定
    let seatClass = "seat";
    if (p.isUser) seatClass += " you";
    if (i === currentPlayerIndex && !state?.finished) seatClass += " current-player";
    if (p.folded) seatClass += " folded";
    if (i === dealerPosition) seatClass += " dealer";
    
    seat.className = seatClass;
    seat.style.left = `${x}px`;
    seat.style.top = `${y}px`;
    seat.style.width = seatW + "px";
    seat.style.height = seatH + "px";

    // 直近アクションテキスト
    let actText = "";
    if (latestActions[p.name]) {
      const a = latestActions[p.name];
      if (a.action === "fold") actText = "フォールド";
      else if (a.action === "call") actText = `コール（${a.amount}）`;
      else if (a.action === "check") actText = "チェック";
      else if (a.action === "raise") actText = `レイズ（${a.amount}）`;
      else if (a.action === "bet") actText = `ベット（${a.amount}）`;
      else actText = a.action;
    }

    // 現在のプレイヤーインジケーター
    const currentPlayerIndicator = i === currentPlayerIndex && !state?.finished ? 
      '<div style="color: #ff5722; font-weight: bold; font-size: 0.8em;">▶ アクション中</div>' : '';

    // ディーラーボタンインジケーター
    const dealerButtonIndicator = i === dealerPosition ? 
      '<div style="color: #1976d2; font-weight: bold; font-size: 0.7em;">🟡 DEALER</div>' : '';

    // アクション表示
    const actionDisplay = actText ? `<div class="player-action-log">${actText}</div>` : '';

    seat.innerHTML = `
      <div class="player-name">${p.name}</div>
      <div class="player-pos">${p.position}</div>
      <div class="player-stack">Stack:${p.stack}</div>
      ${dealerButtonIndicator}
      ${currentPlayerIndicator}
      ${actionDisplay}
      ${p.hand && p.hand.length === 2 ? `<div style="display:flex; justify-content:center; gap:4px; margin-top:6px;">
        ${p.isUser || state.finished ? `
          <span class="card ${cardSuit(p.hand[0])}">${p.hand[0]}</span>
          <span class="card ${cardSuit(p.hand[1])}">${p.hand[1]}</span>
        ` : `
          <span class="card back"></span>
          <span class="card back"></span>
        `}
      </div>` : ""}
    `;
    table.appendChild(seat);

    // ★ チップ表示を追加 ★
    if (p.bet > 0 && !state?.finished) {
      const chipPos = calculateChipPosition(i, w, h);
      const chipStack = document.createElement("div");
      chipStack.className = "chip-stack";
      chipStack.style.left = `${chipPos.x}px`;
      chipStack.style.top = `${chipPos.y}px`;
      
      chipStack.innerHTML = `
        <div class="chip"></div>
        <div class="chip-amount">${p.bet}</div>
      `;
      
      table.appendChild(chipStack);
    }
  }

  // ボードカード中央（テーブル内側）
  const boardDiv = document.createElement("div");
  boardDiv.className = "table-board-cards";
  boardDiv.innerHTML = boardCards.map(c => `<span class="card ${cardSuit(c)}">${c}</span>`).join('');
  table.appendChild(boardDiv);

  // ポット情報を中央に表示（テーブル内側）
  const potDiv = document.createElement("div");
  potDiv.className = "table-pot-info";
  potDiv.innerHTML = `<div class="pot-amount">POT: ${state.pot} チップ</div>`;
  table.appendChild(potDiv);

  return table;
}
// ▲▲▲ 楕円テーブル描画 ▲▲▲

// --- デッキ＆カード ---
function makeDeck() {
  const suits = ["♠", "♥", "♦", "♣"];
  const ranks = ["2","3","4","5","6","7","8","9","T","J","Q","K","A"];
  let cards = [];
  for (let s of suits) for (let r of ranks) cards.push(r+s);
  shuffle(cards);
  return cards;
}

function makePlayers() {
  let arr = [];
  const currentPositions = assignPositions(dealerPosition);
  
  for (let i = 0; i < PLAYER_NUM; i++) {
    arr.push({
      name: i === 0 ? "あなた" : `CPU${i}`,
      position: currentPositions[i],
      stack: START_STACK,
      bet: 0,
      hand: [],
      folded: false,
      isUser: i === 0,
      actions: [],
      hasActedThisRound: false,
    });
  }
  return arr;
}

function cloneStateForHistory(state) {
  return JSON.parse(JSON.stringify({
    gameNumber: (window.allHistory?.length || 0) + 1,
    handNumber: handNumber,
    dealerPosition: dealerPosition,
    timestamp: new Date().toISOString(),
    gameResult: {
      stage: state.stage,
      pot: state.pot,
      board: [...state.board],
      finished: state.finished
    },
    players: state.players.map((p, i) => ({
      name: p.name,
      position: p.position,
      isUser: p.isUser,
      startingStack: state.handStartStacks[i], // ハンド開始時のスタック
      finalStack: p.stack,
      stackChange: p.stack - state.handStartStacks[i], // 正確な収支
      hand: p.hand,
      folded: p.folded,
      totalBet: p.bet,
      actions: [...p.actions]
    })),
    actionLog: [...state.actionLog],
    detailedActions: state.actionLog.map(action => ({
      ...action,
      timestamp: new Date().toISOString(),
      potAfterAction: state.pot
    }))
  }));
}

// --- 初期化 ---
function initGame() {
  state = {
    deck: makeDeck(),
    board: [],
    pot: 0,
    players: makePlayers(),
    stage: "プリフロップ",
    currentPlayer: 0,
    minBet: BB,
    currentBet: BB,
    lastAggressor: null,
    actionLog: [],
    history: [],
    finished: false,
    showdownResult: null
  };
  
  // 各ハンド開始時のスタック（アンティ・ブラインド控除前）を記録
  const handStartStacks = state.players.map(p => p.stack);

  // アンティを徴収
  for (let i = 0; i < PLAYER_NUM; i++) {
    state.players[i].stack -= ANTE;
    state.pot += ANTE;
  }

  // SBとBBの位置を動的に決定
  const sbPosition = (dealerPosition + 1) % PLAYER_NUM;
  const bbPosition = (dealerPosition + 2) % PLAYER_NUM;
  const utgPosition = (dealerPosition + 3) % PLAYER_NUM;

  // SBとBBを徴収
  state.players[sbPosition].stack -= SB;
  state.players[sbPosition].bet = SB;
  state.pot += SB;
  
  state.players[bbPosition].stack -= BB;
  state.players[bbPosition].bet = BB;
  state.pot += BB;
  
  state.currentBet = BB;
  state.minBet = BB;

  // ハンドを配る
  for (let p of state.players) {
    p.hand = [state.deck.pop(), state.deck.pop()];
    p.folded = false;
    p.bet = p.bet || 0;
    p.actions = [];
    p.hasActedThisRound = false;
  }
  
  // プリフロップではSBとBBは既にアクションしたとみなす
  state.players[sbPosition].hasActedThisRound = true;
  state.players[bbPosition].hasActedThisRound = true;
  
  // UTGからアクションスタート（BBの次のプレイヤー）
  state.currentPlayer = utgPosition;
  
  state.actionLog = [];
  state.history = [];
  state.finished = false;
  state.showdownResult = null;
  
  // このハンド開始時のスタックを保存
  state.handStartStacks = handStartStacks;
  
  renderGame();
}

// --- 次のハンドを開始 ---
function nextHand() {
  // ディーラーボタンを時計回りに移動
  dealerPosition = (dealerPosition + 1) % PLAYER_NUM;
  handNumber++;
  
  // 新しいハンドを開始
  initGame();
}

// --- ゲーム画面描画 ---
// --- ゲーム画面描画（修正版：位置入れ替え対応） ---
function renderGame() {
  const root = document.getElementById("game-section");
  root.innerHTML = "";
  
  if (state.finished) {
    let winnerText = '';
    if (state.showdownResult) {
      winnerText += `<div style="margin:1em 0 0.7em 0; font-size:1.08em;"><b>【勝敗結果】</b><br>`;
      for (const win of state.showdownResult.winners) {
        winnerText += `<b>${win.name}</b>（${win.position}）<br>
          役：${win.handName} <span class="card-list">${win.hand.map(c=>`<span class="card ${cardSuit(c)}">${c}</span>`).join('')}</span>
          <br>獲得: ${state.showdownResult.winAmount}チップ<br><br>`;
      }
      winnerText += `</div>`;
    }
    let profit = state.players[0].stack - state.handStartStacks[0];
    winnerText += `<b>あなたの収支：</b><span style="color:${profit>=0?'#1976d2':'#e53935'};">${profit>=0?'+':''}${profit}</span> チップ<br>`;

    // ゲーム終了時は全員のハンドを表示
    root.appendChild(renderEllipseTable(state.players, state.board, state.actionLog));

    root.innerHTML += `
      <h2>ハンド #${handNumber} 終了</h2>
      ${winnerText}
      <button onclick="showHistory()">対戦履歴を見る</button>
      <button onclick="nextHand()">次のハンド</button>
      <button onclick="initGame()">新しいゲーム</button>
    `;
    if (!state.loggedHistory) {
      window.allHistory.push({
        ...cloneStateForHistory(state),
        showdownResult: state.showdownResult,
        profit: profit,
        board: [...state.board]
      });
      state.loggedHistory = true;
    }
    return;
  }

 // プレイ画面：全プレイヤーのハンドを表示
  root.appendChild(renderEllipseTable(state.players, state.board, state.actionLog, state.currentPlayer));

  // アクションボタン（全プレイヤー用）- テーブルのすぐ下に表示
  const currentPlayer = state.players[state.currentPlayer];
  if (!currentPlayer.folded && !state.finished) {
    const actionDiv = document.createElement("div");
    actionDiv.className = "action-area";
    actionDiv.style.margin = "";
    
    const callAmount = state.currentBet - currentPlayer.bet;
    const playerTypeText = currentPlayer.isUser ? "あなた" : `${currentPlayer.name}（CPU）`;
    
    // アクションボタンを決定
    let actionButtons = '';
    
    if (callAmount > 0) {
      // コール/レイズ/フォールドの状況
      actionButtons = `
        <button onclick="playerAction('fold', ${state.currentPlayer})">フォールド</button>
        <button onclick="playerAction('call', ${state.currentPlayer})">コール（${callAmount}）</button>
        <button onclick="playerAction('raise', ${state.currentPlayer})">レイズ</button>
      `;
    } else {
      // チェック/ベット/フォールドの状況
      actionButtons = `
        <button onclick="playerAction('fold', ${state.currentPlayer})">フォールド</button>
        <button onclick="playerAction('check', ${state.currentPlayer})">チェック</button>
        <button onclick="playerAction('bet', ${state.currentPlayer})">ベット</button>
      `;
    }
    
    actionDiv.innerHTML = `
      <b>アクションを選択</b>
      <div class="action-list">
        ${actionButtons}
      </div>
    `;
    root.appendChild(actionDiv);
  }

  // 現在のプレイヤー情報を表示（アクションボタンの後に表示）
  const playerInfoDiv = document.createElement("div");
  playerInfoDiv.className = "game-info-panel";
  playerInfoDiv.innerHTML = `
    <b>ハンド #${handNumber}</b> - ディーラー: ${state.players[dealerPosition].name}<br>
    <b>現在のアクション:</b> ${currentPlayer.name} (${currentPlayer.position})<br>
    <b>現在のベット:</b> ${state.currentBet} チップ<br>
    <b>ポット:</b> ${state.pot} チップ<br>
    <b>ステージ:</b> ${state.stage}
  `;
  root.appendChild(playerInfoDiv);
  }
  
  window.scrollTo({top:0, behavior:'smooth'});


// --- 統一されたアクション処理関数 ---
function playerAction(actionType, playerIndex) {
  let player = state.players[playerIndex];
  
  if (actionType === "fold") {
    player.folded = true;
    player.hasActedThisRound = true;
    logAction(player, "fold", 0);
    nextPlayer();
  } else if (actionType === "check") {
    // チェック：追加ベットなし
    player.hasActedThisRound = true;
    logAction(player, "check", 0);
    nextPlayer();
  } else if (actionType === "call") {
    const callAmount = state.currentBet - player.bet;
    if (callAmount > player.stack) {
      // オールイン
      const allInAmount = player.stack;
      state.pot += allInAmount;
      player.bet += allInAmount;
      player.stack = 0;
      logAction(player, "call", allInAmount);
    } else {
      player.stack -= callAmount;
      player.bet += callAmount;
      state.pot += callAmount;
      logAction(player, "call", callAmount);
    }
    player.hasActedThisRound = true;
    nextPlayer();
  } else if (actionType === "bet") {
    let betAmount = prompt(`${player.name}のベット額を入力してください\n（例: ${BB}）`);
    betAmount = parseInt(betAmount);
    
    if (isNaN(betAmount) || betAmount <= 0) {
      alert("無効な金額です。正の値を入力してください。");
      return;
    }
    
    if (betAmount > player.stack) {
      betAmount = player.stack; // オールイン
      alert(`${player.name}はオールインします（${betAmount}）`);
    }
    
    player.stack -= betAmount;
    player.bet += betAmount;
    state.pot += betAmount;
    state.currentBet = betAmount;
    state.lastAggressor = playerIndex;
    player.hasActedThisRound = true;
    
    // ベットした場合、他のプレイヤーは再度アクションが必要
    resetActionsAfterAggression(playerIndex);
    
    logAction(player, "bet", betAmount);
    nextPlayer();
  } else if (actionType === "raise") {
    let raiseTo = prompt(`${player.name}のレイズ額を入力してください\n（現在ベット:${state.currentBet} 例: ${state.currentBet + 6}）`);
    raiseTo = parseInt(raiseTo);
    
    if (isNaN(raiseTo) || raiseTo <= state.currentBet) {
      alert("無効な金額です。現在のベット額より大きい値を入力してください。");
      return;
    }
    
    const maxRaise = player.stack + player.bet;
    if (raiseTo > maxRaise) {
      raiseTo = maxRaise; // オールイン
      alert(`${player.name}はオールインします（${raiseTo}）`);
    }
    
    const pay = raiseTo - player.bet;
    player.stack -= pay;
    player.bet += pay;
    state.pot += pay;
    state.currentBet = raiseTo;
    state.lastAggressor = playerIndex;
    player.hasActedThisRound = true;
    
    // レイズした場合、他のプレイヤーは再度アクションが必要
    resetActionsAfterAggression(playerIndex);
    
    logAction(player, "raise", pay);
    nextPlayer();
  }
}

// レイズ/ベット後に他のプレイヤーのアクション状態をリセット
function resetActionsAfterAggression(aggressorIndex) {
  for (let i = 0; i < state.players.length; i++) {
    if (i !== aggressorIndex && !state.players[i].folded) {
      state.players[i].hasActedThisRound = false;
    }
  }
}

function logAction(player, act, amount) {
  player.actions.push({ stage: state.stage, action: act, amount, stack: player.stack });
  state.actionLog.push({
    player: player.name,
    stage: state.stage,
    action: act,
    amount,
    stack: player.stack,
  });
}

// --- CPU自動アクション（従来の機能を保持） ---
async function cpuAutoAction() {
  let p = state.players[state.currentPlayer];
  if (p.folded) { 
    nextPlayer(); 
    return; 
  }
  
  // CPU思考中の表示
  const actionButtons = document.querySelector('.action-list');
  if (actionButtons) {
    actionButtons.innerHTML = '<div style="color: #666; text-align: center; padding: 20px;">🤖 CPU思考中...</div>';
  }
  
  await sleep(800 + Math.random() * 700);
  
  const callAmount = state.currentBet - p.bet;
  let act, pay = 0;
  
  // CPU判断ロジック
  if (p.stack <= 0) { 
    act = callAmount > 0 ? "call" : "check"; 
    pay = 0; 
  } else if (callAmount > 15 && Math.random() < 0.55) { 
    act = "fold"; 
  } else if (Math.random() < 0.12 && p.stack > state.currentBet * 2) { 
    act = callAmount > 0 ? "raise" : "bet";
  } else { 
    act = callAmount > 0 ? "call" : "check";
  }

  if (act === "fold") {
    p.folded = true;
    p.hasActedThisRound = true;
    logAction(p, "fold", 0);
  } else if (act === "check") {
    p.hasActedThisRound = true;
    logAction(p, "check", 0);
  } else if (act === "call") {
    if (callAmount > p.stack) {
      const allInAmount = p.stack;
      state.pot += allInAmount;
      p.bet += allInAmount;
      p.stack = 0;
      logAction(p, "call", allInAmount);
    } else {
      p.stack -= callAmount;
      p.bet += callAmount;
      state.pot += callAmount;
      logAction(p, "call", callAmount);
    }
    p.hasActedThisRound = true;
  } else if (act === "bet") {
    let betAmount = 3 + Math.floor(Math.random() * 6);
    betAmount = Math.min(betAmount, p.stack);
    p.stack -= betAmount;
    p.bet += betAmount;
    state.pot += betAmount;
    state.currentBet = betAmount;
    state.lastAggressor = state.currentPlayer;
    p.hasActedThisRound = true;
    resetActionsAfterAggression(state.currentPlayer);
    logAction(p, "bet", betAmount);
  } else if (act === "raise") {
    let raiseTo = state.currentBet + 3 + Math.floor(Math.random() * 6);
    raiseTo = Math.min(raiseTo, p.stack + p.bet);
    const pay = raiseTo - p.bet;
    p.stack -= pay;
    p.bet += pay;
    state.pot += pay;
    state.currentBet = raiseTo;
    state.lastAggressor = state.currentPlayer;
    p.hasActedThisRound = true;
    resetActionsAfterAggression(state.currentPlayer);
    logAction(p, "raise", pay);
  }
  
  renderGame();
  await sleep(400 + Math.random() * 400);
  nextPlayer();
}

// --- 修正された次のプレイヤー処理 ---
function nextPlayer() {
  // 生きているプレイヤーを取得
  let alivePlayers = state.players.filter(p => !p.folded);
  
  // 1人しか残っていない場合はゲーム終了
  if (alivePlayers.length === 1) {
    state.finished = true;
    const winner = alivePlayers[0];
    winner.stack += state.pot;
    renderGame();
    return;
  }

  // 次のプレイヤーを探す
  do {
    state.currentPlayer = (state.currentPlayer + 1) % PLAYER_NUM;
  } while (state.players[state.currentPlayer].folded);

  // ベッティングラウンド終了条件をチェック
  if (isBettingRoundComplete()) {
    nextStage();
    return;
  }

  renderGame();
}

// ベッティングラウンドの完了判定
function isBettingRoundComplete() {
  const alivePlayers = state.players.filter(p => !p.folded);
  
  // 全員が同じ額をベットしているかチェック
  const allSameBet = alivePlayers.every(p => p.bet === state.currentBet);
  
  // 全員がこのラウンドでアクションしたかチェック
  const allHaveActed = alivePlayers.every(p => p.hasActedThisRound);
  
  // 両方の条件が満たされた場合のみラウンド終了
  return allSameBet && allHaveActed;
}

// --- ストリート遷移 ---
function nextStage() {
  // 全プレイヤーのベットとアクション状態をリセット
  for (let p of state.players) {
    p.bet = 0;
    p.hasActedThisRound = false;
  }

  if (state.stage === "プリフロップ") {
    state.board = [state.deck.pop(), state.deck.pop(), state.deck.pop()];
    state.stage = "フロップ";
  } else if (state.stage === "フロップ") {
    state.board.push(state.deck.pop());
    state.stage = "ターン";
  } else if (state.stage === "ターン") {
    state.board.push(state.deck.pop());
    state.stage = "リバー";
  } else if (state.stage === "リバー") {
    state.finished = true;
    for (let p of state.players) {
      if (!p.folded) p.showHand = true;
    }
    state.showdownResult = judgeWinners(state.players, state.board, state.pot);

    // ★ 勝者にポットを分配する処理を追加
    if (state.showdownResult?.winners) {
      const winAmount = state.showdownResult.winAmount;
      for (let winner of state.showdownResult.winners) {
        const winPlayer = state.players.find(p => p.name === winner.name);
        if (winPlayer) winPlayer.stack += winAmount;
      }
    }

    renderGame();
    return;
  
  }
  
  state.currentBet = 0;
  state.minBet = BB;
  state.lastAggressor = null;
  
  // フロップ以降は、SB（ディーラーボタンの次のプレイヤー）から開始
  const sbPosition = (dealerPosition + 1) % PLAYER_NUM;
  state.currentPlayer = sbPosition;
  
  // フォールドしていない最初のプレイヤーを見つける
  while (state.players[state.currentPlayer].folded) {
    state.currentPlayer = (state.currentPlayer + 1) % PLAYER_NUM;
  }
  
  renderGame();
}

// --- 対戦履歴（一覧） ---
function showHistory() {
  document.getElementById("game-section").style.display = "none";
  document.getElementById("history-section").style.display = "block";
  document.getElementById("history-detail").style.display = "none";
  showAllHistory();
}
function showAllHistory() {
  let minProfit = Number(document.getElementById("min-profit")?.value || -9999);
  let maxProfit = Number(document.getElementById("max-profit")?.value || 9999);

  let list = window.allHistory || [];
  list = list.filter(h => h.profit >= minProfit && h.profit <= maxProfit);

  let html = "";
  if (!list.length) html = "<div style='color:#999'>該当する履歴がありません</div>";
  list.forEach((h, idx) => {
    html += `<div style="border-bottom:1px solid #ddd;padding:6px 0;">
      <b>ハンド #${h.handNumber || idx+1}</b> (ディーラー: ${h.players[h.dealerPosition || 0]?.name || 'Player'})
      収支：<span style="color:${h.profit>=0?'#1976d2':'#e53935'};">${h.profit>=0?'+':''}${h.profit}</span> チップ
      <button onclick="showSingleHistory(${idx})">詳細</button>
    </div>`;
  });
  document.getElementById("history-list").innerHTML = html;
  document.getElementById("history-detail").style.display = "none";
}
function showSingleHistory(idx) {
  const h = window.allHistory[idx];
  let html = `<h3>ハンド #${h.handNumber || idx+1} 詳細</h3>`;
  html += `<p><b>ディーラー:</b> ${h.players[h.dealerPosition || 0]?.name || 'Player'} (座席 ${(h.dealerPosition || 0) + 1})</p>`;
  
  // 履歴画面では全員分のハンド表示
  html += renderEllipseTable(h.players, h.board, h.actionLog).outerHTML;

  // ポジション情報を表示
  html += `<div style="margin: 15px 0; padding: 10px; background: #f5f5f5; border-radius: 8px;">`;
  html += `<b>ポジション配置:</b><br>`;
  h.players.forEach((p, i) => {
    html += `${p.name}: ${p.position}${i === (h.dealerPosition || 0) ? ' (DEALER)' : ''}<br>`;
  });
  html += `</div>`;

  // ボード進行表示（ストリートごと）
  const boardOnStreet = {
    "プリフロップ": [],
    "フロップ": h.board.slice(0, 3),
    "ターン": h.board.slice(0, 4),
    "リバー": h.board.slice(0, 5),
  };
  
  for (const stage of ["プリフロップ", "フロップ", "ターン", "リバー"]) {
    html += `<b>${stage}</b>`;
    html += ` <span class="card-list">`;
    boardOnStreet[stage].forEach(card => {
      html += `<span class="card ${cardSuit(card)}">${card}</span>`;
    });
    html += `</span><br>`;
    
    for (let p of h.players) {
      html += `<span class="player-name">${p.name} (${p.position})</span> `;
      if (p.hand && p.hand.length === 2) {
        html += `<span class="card-list">
          <span class="card ${cardSuit(p.hand[0])}">${p.hand[0]}</span>
          <span class="card ${cardSuit(p.hand[1])}">${p.hand[1]}</span>
        </span>`;
      }
      let acts = p.actions.filter(a => a.stage === stage).map(a =>
        `${a.action} (${a.amount})`
      ).join(" → ");
      html += `　${acts}<br>`;
    }
    html += `<br>`;
  }
  
  if (h.showdownResult) {
    html += `<b>【勝敗結果】</b><br>`;
    for (const win of h.showdownResult.winners) {
      html += `<b>${win.name}</b>（${win.position}）<br>
        役：${win.handName} <span class="card-list">${win.hand.map(c=>`<span class="card ${cardSuit(c)}">${c}</span>`).join('')}</span>
        <br>獲得: ${h.showdownResult.winAmount}チップ<br><br>`;
    }
  }
  
  html += `<b>あなたの収支：</b><span style="color:${h.profit>=0?'#1976d2':'#e53935'};">${h.profit>=0?'+':''}${h.profit}</span> チップ<br>`;
  html += `<button onclick="showAllHistory()">一覧に戻る</button>`;
  
  document.getElementById("history-detail").innerHTML = html;
  document.getElementById("history-detail").style.display = "";
}

// --- 戻る ---
document.getElementById("back-to-game-btn").onclick = () => {
  document.getElementById("history-section").style.display = "none";
  document.getElementById("game-section").style.display = "";
  renderGame();
};
document.getElementById("reset-btn").onclick = () => { 
  dealerPosition = 0; 
  handNumber = 1;
  // 全プレイヤーのスタックを初期値にリセット
  for (let i = 0; i < PLAYER_NUM; i++) {
    if (state && state.players[i]) {
      state.players[i].stack = START_STACK;
    }
  }
  initGame(); 
};
document.getElementById("show-history-btn").onclick = () => { showHistory(); };
document.getElementById("filter-btn").onclick = () => { showAllHistory(); };

initGame();
// --- キーボード操作対応 ---
document.addEventListener('keydown', (event) => {
  const key = event.key.toLowerCase();
  const currentPlayer = state.players[state.currentPlayer];

  // あなたのターンでなければ無視
  // if (!currentPlayer || !currentPlayer.isUser || state.finished) return;

  const callAmount = state.currentBet - currentPlayer.bet;

  if (key === 'f') {
    playerAction('fold', state.currentPlayer); // F: フォールド
  } else if (key === 'c') {
    if (callAmount > 0) {
      playerAction('call', state.currentPlayer); // C: コール
    } else {
      playerAction('check', state.currentPlayer); // C: チェック
    }
  } else if (key === 'r') {
    if (callAmount > 0) {
      playerAction('raise', state.currentPlayer); // R: レイズ
    } else {
      playerAction('bet', state.currentPlayer);   // R: ベット
    }
  }
});

// --- 役評価 ---
function judgeWinners(players, board, pot) {
  const alive = players.filter(p => !p.folded);
  let scores = alive.map(p => {
    const allCards = [...p.hand, ...board];
    const evalResult = evaluateHandSimple(allCards);
    return {
      ...p,
      score: evalResult.score,
      handName: evalResult.handName,
      hand: evalResult.bestHand
    };
  });

  scores.sort((a, b) => b.score - a.score);
  const bestScore = scores[0].score;
  const winners = scores.filter(s => s.score === bestScore);
  const winAmount = Math.floor(pot / winners.length);

  return { winners, winAmount };
}

function evaluateHandSimple(cards) {
  let combs = k_combinations(cards, 5);
  let maxScore = 0, handName = "ハイカード", bestHand = [];
  for (let hand of combs) {
    let r = rank5(hand);
    if (r.score > maxScore) {
      maxScore = r.score;
      handName = r.handName;
      bestHand = r.sortedHand; // ソート済みのハンドを使用
    }
  }
  return { score: maxScore, handName, bestHand };
}

function rank5(hand) {
  const order = ["ハイカード","ワンペア","ツーペア","スリーカード","ストレート","フラッシュ","フルハウス","フォーカード","ストレートフラッシュ"];
  const ranks = "23456789TJQKA".split("");
  
  // カードを数値とスートに分離
  let cardObjs = hand.map(c => ({
    rank: ranks.indexOf(c[0]),
    suit: c[1],
    card: c
  }));
  
  // ランクでソート（高い順）
  cardObjs.sort((a, b) => b.rank - a.rank);
  
  let vals = cardObjs.map(c => c.rank);
  let suits = cardObjs.map(c => c.suit);
  let counts = {};
  for (let v of vals) counts[v] = (counts[v]||0)+1;
  
  let uniq = Object.keys(counts).map(Number).sort((a,b) => b-a);
  let flush = suits.every(s => s === suits[0]);
  
  // ストレート判定（A-5ストレートも考慮）
  let straight = false;
  let straightHigh = 0;
  
  if (uniq.length === 5) {
    // 通常のストレート
    if (uniq[0] - uniq[4] === 4) {
      straight = true;
      straightHigh = uniq[0];
    }
    // A-5ストレート (A,5,4,3,2)
    else if (uniq[0] === 12 && uniq[1] === 3 && uniq[2] === 2 && uniq[3] === 1 && uniq[4] === 0) {
      straight = true;
      straightHigh = 3; // 5ハイストレート
      // A-5ストレートの場合は5を最高位とする順序に並び替え
      cardObjs = cardObjs.filter(c => c.rank !== 12).concat(cardObjs.filter(c => c.rank === 12));
    }
  }
  
  // 役に応じてカードを適切にソート
  let sortedHand = [];
  
  if (straight && flush) {
    // ストレートフラッシュ: ストレート順
    if (straightHigh === 3) { // A-5ストレート
      sortedHand = cardObjs.map(c => c.card);
    } else {
      sortedHand = cardObjs.map(c => c.card);
    }
    return {score: 9000 + straightHigh, handName: order[8], sortedHand};
  }
  
  if (Object.values(counts).includes(4)) {
    // フォーカード: 4枚組 + キッカー
    let fourRank = uniq.find(v => counts[v] === 4);
    let kicker = uniq.find(v => counts[v] === 1);
    sortedHand = cardObjs.filter(c => c.rank === fourRank).map(c => c.card)
                        .concat(cardObjs.filter(c => c.rank === kicker).map(c => c.card));
    return {score: 8000 + fourRank, handName: order[7], sortedHand};
  }
  
  if (Object.values(counts).includes(3) && Object.values(counts).includes(2)) {
    // フルハウス: 3枚組 + ペア
    let threeRank = uniq.find(v => counts[v] === 3);
    let pairRank = uniq.find(v => counts[v] === 2);
    sortedHand = cardObjs.filter(c => c.rank === threeRank).map(c => c.card)
                        .concat(cardObjs.filter(c => c.rank === pairRank).map(c => c.card));
    return {score: 7000 + threeRank, handName: order[6], sortedHand};
  }
  
  if (flush) {
    // フラッシュ: 高い順
    sortedHand = cardObjs.map(c => c.card);
    return {score: 6000 + vals[0], handName: order[5], sortedHand};
  }
  
  if (straight) {
    // ストレート: ストレート順
    sortedHand = cardObjs.map(c => c.card);
    return {score: 5000 + straightHigh, handName: order[4], sortedHand};
  }
  
  if (Object.values(counts).includes(3)) {
    // スリーカード: 3枚組 + キッカー2枚（高い順）
    let threeRank = uniq.find(v => counts[v] === 3);
    let kickers = uniq.filter(v => counts[v] === 1).sort((a,b) => b-a);
    sortedHand = cardObjs.filter(c => c.rank === threeRank).map(c => c.card);
    for (let k of kickers) {
      sortedHand = sortedHand.concat(cardObjs.filter(c => c.rank === k).map(c => c.card));
    }
    return {score: 4000 + threeRank, handName: order[3], sortedHand};
  }
  
  if (Object.values(counts).filter(c => c === 2).length === 2) {
    // ツーペア: 高ペア + 低ペア + キッカー
    let pairs = uniq.filter(v => counts[v] === 2).sort((a,b) => b-a);
    let kicker = uniq.find(v => counts[v] === 1);
    sortedHand = cardObjs.filter(c => c.rank === pairs[0]).map(c => c.card)
                        .concat(cardObjs.filter(c => c.rank === pairs[1]).map(c => c.card))
                        .concat(cardObjs.filter(c => c.rank === kicker).map(c => c.card));
    return {score: 3000 + pairs[0] * 100 + pairs[1], handName: order[2], sortedHand};
  }
  
  if (Object.values(counts).includes(2)) {
    // ワンペア: ペア + キッカー3枚（高い順）
    let pairRank = uniq.find(v => counts[v] === 2);
    let kickers = uniq.filter(v => counts[v] === 1).sort((a,b) => b-a);
    sortedHand = cardObjs.filter(c => c.rank === pairRank).map(c => c.card);
    for (let k of kickers) {
      sortedHand = sortedHand.concat(cardObjs.filter(c => c.rank === k).map(c => c.card));
    }
    return {score: 2000 + pairRank, handName: order[1], sortedHand};
  }
  
  // ハイカード: 高い順
  sortedHand = cardObjs.map(c => c.card);
  return {score: 1000 + vals[0], handName: order[0], sortedHand};
}

function k_combinations(set, k) {
  if (k > set.length || k === 0) return [];
  if (k === set.length) return [set];
  if (k === 1) return set.map(e => [e]);
  let combs = [];
  for (let i = 0; i < set.length - k + 1; i++) {
    let head = set.slice(i, i+1);
    let tailcombs = k_combinations(set.slice(i+1), k-1);
    for (let comb of tailcombs) combs.push(head.concat(comb));
  }
  return combs;
}

// --- 履歴エクスポート用関数 ---
function exportHistoryAsJSON() {
  // より詳細で整理されたデータ構造を作成
  const detailedHistory = window.allHistory.map((game, index) => {
    // 各プレイヤーの詳細統計を計算
    const playerStats = game.players.map(player => {
      const playerActions = game.actionLog.filter(log => log.player === player.name);
      const actionSummary = {
        folds: playerActions.filter(a => a.action === 'fold').length,
        calls: playerActions.filter(a => a.action === 'call').length,
        raises: playerActions.filter(a => a.action === 'raise').length,
        totalAmountBet: playerActions.reduce((sum, a) => sum + (a.amount || 0), 0)
      };

      return {
        playerInfo: {
          name: player.name,
          position: player.position,
          isUser: player.isUser
        },
        chipInfo: {
          startingStack: START_STACK,
          finalStack: player.stack,
          profit: player.stack - START_STACK,
          anteAndBlinds: ANTE + (player.position === 'SB' ? SB : 0) + (player.position === 'BB' ? BB : 0)
        },
        handInfo: {
          holeCards: player.hand,
          folded: player.folded,
          showedDown: !player.folded && game.stage === 'リバー'
        },
        actionSummary: actionSummary,
        detailedActions: playerActions
      };
    });

    // ゲーム全体の統計
    const gameStats = {
      handNumber: game.handNumber || index + 1,
      dealerPosition: game.dealerPosition || 0,
      dealerName: game.players[game.dealerPosition || 0]?.name || 'Player',
      totalPot: game.pot,
      boardCards: game.board,
      finalStage: game.stage,
      numberOfPlayers: game.players.length,
      playersWhoFolded: game.players.filter(p => p.folded).length,
      playersInShowdown: game.players.filter(p => !p.folded).length
    };

    // 勝者情報
    const winnerInfo = game.showdownResult ? {
      winners: game.showdownResult.winners.map(w => ({
        name: w.name,
        position: w.position,
        hand: w.hand,
        handRank: w.handName,
        amountWon: game.showdownResult.winAmount
      })),
      totalWinAmount: game.showdownResult.winAmount * game.showdownResult.winners.length
    } : null;

    return {
      gameInfo: {
        handNumber: game.handNumber || index + 1,
        dealerPosition: game.dealerPosition || 0,
        timestamp: game.timestamp || new Date().toISOString(),
        gameSettings: {
          playerCount: PLAYER_NUM,
          startingStack: START_STACK,
          smallBlind: SB,
          bigBlind: BB,
          ante: ANTE
        }
      },
      gameStats: gameStats,
      playerDetails: playerStats,
      winnerInfo: winnerInfo,
      chronologicalActions: game.actionLog.map((action, actionIndex) => ({
        actionNumber: actionIndex + 1,
        stage: action.stage,
        player: action.player,
        action: action.action,
        amount: action.amount || 0,
        stackAfterAction: action.stack,
        timestamp: new Date().toISOString()
      }))
    };
  });

  // 全体統計も追加
  const overallStats = {
    totalHands: detailedHistory.length,
    userStats: {
      totalProfit: detailedHistory.reduce((sum, game) => {
        const userPlayer = game.playerDetails.find(p => p.playerInfo.isUser);
        return sum + (userPlayer ? userPlayer.chipInfo.profit : 0);
      }, 0),
      handsWon: detailedHistory.filter(game => {
        return game.winnerInfo?.winners.some(w => w.name === 'あなた');
      }).length,
      averageProfit: detailedHistory.length > 0 ? 
        detailedHistory.reduce((sum, game) => {
          const userPlayer = game.playerDetails.find(p => p.playerInfo.isUser);
          return sum + (userPlayer ? userPlayer.chipInfo.profit : 0);
        }, 0) / detailedHistory.length : 0
    },
    exportTimestamp: new Date().toISOString()
  };

  const exportData = {
    metadata: {
      appName: "テキサスホールデム デモ（ポジションローテーション対応）",
      exportVersion: "3.0",
      exportDate: new Date().toISOString(),
      dataDescription: "ポーカーゲームの詳細履歴データ（ポジションローテーション、プレイヤーハンド、アクション、チップ変動を含む）"
    },
    overallStats: overallStats,
    hands: detailedHistory
  };

  const dataStr = JSON.stringify(exportData, null, 2);
  const blob = new Blob([dataStr], {type: "application/json"});
  const url = URL.createObjectURL(blob);
  const fileName = `poker-detailed-history-${new Date().toISOString().slice(0,10)}.json`;

  const a = document.createElement("a");
  a.href = url;
  a.download = fileName;
  a.click();
  URL.revokeObjectURL(url);

  // エクスポート完了のメッセージを表示
  alert(`履歴をエクスポートしました！\nファイル名: ${fileName}\n\n含まれる情報:\n• ポジションローテーション情報\n• 各プレイヤーのハンド\n• 詳細なアクション履歴\n• チップの変動\n• ゲーム統計`);
}

// 起動時にイベントをバインド
document.getElementById("export-history-btn").onclick = exportHistoryAsJSON;