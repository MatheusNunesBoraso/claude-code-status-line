<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-Status_Line-blueviolet?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0wIDE4Yy00LjQyIDAtOC0zLjU4LTgtOHMzLjU4LTggOC04IDggMy41OCA4IDgtMy41OCA4LTggOHoiLz48L3N2Zz4=" alt="Claude Code Status Line"/>
  <br/>
  <img src="https://img.shields.io/badge/bash-pure_bash-green?style=flat-square&logo=gnubash&logoColor=white" alt="Pure Bash"/>
  <img src="https://img.shields.io/badge/dependencies-zero-brightgreen?style=flat-square" alt="Zero Dependencies"/>
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=flat-square" alt="Cross Platform"/>
  <img src="https://img.shields.io/github/license/MatheusNunesBoraso/claude-code-status-line?style=flat-square" alt="License"/>
</p>

<h1 align="center">🐙 Claude Code — Status Line</h1>

<p align="center">
  <strong>Uma barra de status customizada para o Claude Code CLI que mostra modelo, projeto, branch, uso de contexto e rate limits em tempo real.</strong>
</p>

<p align="center">
  <em>Zero dependencias. Pure bash. Cross-platform.</em>
</p>

---

## ✨ Preview

```
⏳ 29% 🧊 - 3h3m │ 📅 8% 🧊 - 5d13h │ 🧠 8% │ 🐙 Opus 5 (1M context)
├─ 📝 +312/-89 │ 🌿 main
└─ 📁 .dev/meu-projeto
```

Sessao apertada, queimando rapido:

```
⏳ 78% 🔥 - 1h12m │ 📅 94% 🔥 - 2d4h │ 🧠 83% │ 🎵 Sonnet 5
├─ 📝 +1204/-377 │ 🌿 feature/auth
└─ 📁 api/backend
```

Fora de repo e sem edicoes — a linha do meio some sozinha:

```
⏳ 3% 🧊 - 4h58m │ 📅 8% 🧊 - 5d2h │ 🧠 5% │ 🌸 Haiku 4.5
└─ 📁 scripts/utils
```

## 📋 O que mostra

| Segmento | Emoji | Cor | Descricao |
|---|---|---|---|
| **Limite 5h** | ⏳ | Dinamica | % usado da janela de 5h + tempo pro reset |
| **Ritmo** | 🧊 / 🔥 | — | Gelo: consumo abaixo do relogio. Fogo: queimando mais rapido que o tempo passa |
| **Limite semanal** | 📅 | Dinamica | % usado da janela de 7 dias + tempo pro reset |
| **Contexto** | 🧠 | Dinamica | % da janela de contexto desta conversa |
| **Modelo** | 🐙 🎵 🌸 🤖 | Ciano | Nome do modelo com emoji dinamico |
| **Diff da sessao** | 📝 | Verde/Vermelho | Linhas adicionadas/removidas (oculto se zero) |
| **Branch** | 🌿 | Magenta | Branch atual do Git (oculto se nao for um repo) |
| **Projeto** | 📁 | Amarelo | Ultimas 2 pastas do caminho do projeto |

### Escala de cor das porcentagens

Vale pros tres indicadores (⏳ 📅 🧠) — a mesma funcao `pct_color` colore todos:

| Faixa | Cor |
|---|---|
| ate 50% | 🟢 Verde |
| 51–75% | 🟡 Amarelo |
| 76–90% | 🟠 Laranja |
| acima de 90% | 🔴 **Vermelho negrito** |

### Ritmo de consumo (🧊 / 🔥)

A porcentagem sozinha nao diz se voce esta indo rapido demais. `29% - 3h3m` numa
janela de 5h significa que 39% do tempo passou e so 29% foi gasto: folga.

O script compara **% consumido** contra **% da janela que ja correu** e mostra
🔥 quando o consumo esta na frente do relogio, 🧊 quando esta atras. O aviso
chega antes da barra virar vermelha.

### Emojis por modelo

| Modelo | Emoji | Motivo |
|---|---|---|
| Opus | 🐙 | Polvo — poderoso e versatil |
| Sonnet | 🎵 | Musica — poetico e harmonioso |
| Haiku | 🌸 | Flor de cerejeira — minimalista e elegante |
| Outros | 🤖 | Robo — generico |

---

## 🚀 Instalacao

### Opcao 1 — Automatica (recomendado)

```bash
git clone https://github.com/MatheusNunesBoraso/claude-code-status-line.git
cd claude-code-status-line
bash install.sh
```

### Opcao 2 — Via IA (Claude Code, Cursor, etc.)

Cole este prompt no seu assistente de IA:

```
Clone o repositorio https://github.com/MatheusNunesBoraso/claude-code-status-line.git
e execute o install.sh para configurar a status line do Claude Code.
```

### Opcao 3 — Manual

```bash
# 1. Copie o script
mkdir -p ~/.claude
curl -fsSL https://raw.githubusercontent.com/MatheusNunesBoraso/claude-code-status-line/main/statusline-command.sh \
  -o ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh

# 2. Adicione ao seu ~/.claude/settings.json
# Se o arquivo ja existe, adicione a chave "statusLine" dentro do JSON:
#
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/statusline-command.sh"
#   }
#
# Se nao existe, crie:
cat > ~/.claude/settings.json << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
EOF

# 3. Reinicie o Claude Code
```

---

## 🗑️ Desinstalacao

```bash
bash ~/.claude/uninstall-statusline.sh
```

Ou manualmente:

```bash
# Remove o script
rm ~/.claude/statusline-command.sh

# Remove a chave "statusLine" do seu settings.json
# (ou restaure o backup)
cp ~/.claude/settings.json.bkp-before-statusline ~/.claude/settings.json
```

---

## 🛠️ Customizacao

O script e puro bash e facil de modificar. Edite `~/.claude/statusline-command.sh`:

**Mudar emojis:**
```bash
case "$model_lower" in
  *opus*)   model_emoji="🐙" ;;  # mude para qualquer emoji
  *sonnet*) model_emoji="🎵" ;;
  *haiku*)  model_emoji="🌸" ;;
  *)        model_emoji="🤖" ;;
esac
```

**Mudar as faixas de cor:**
```bash
pct_color() {
  local p=$1 c
  if   [ "$p" -gt 90 ]; then c="1;31"      # vermelho negrito
  elif [ "$p" -gt 75 ]; then c="38;5;208"  # laranja
  elif [ "$p" -gt 50 ]; then c="33"        # amarelo
  else                       c="32"        # verde
  fi
  ...
}
```

**Mudar cores ANSI:**
```bash
# Cores disponiveis:
# \033[30m Preto    \033[31m Vermelho   \033[32m Verde
# \033[33m Amarelo  \033[34m Azul       \033[35m Magenta
# \033[36m Ciano    \033[37m Branco
# Adicione 1; para negrito: \033[1;36m = Ciano Bold
```

**Mudar o separador:**
```bash
sep="\033[90m │ \033[0m"   # troque │ por |, ·, ou o que quiser
```

**Remover um segmento:**
Comente ou delete o bloco correspondente em `# --- Linha 1/2/3 ---`.

**Reorganizar as linhas:**
Os tres blocos montam `$l1`, `$l2` e `$l3` de forma independente — mover um
segmento de linha e trocar a variavel que ele concatena.

### O espaco antes da linha de modo

A ultima linha do output e um `⠀` (U+2800, braille pattern blank). Nao e enfeite:
o Claude Code apara linhas finais em branco, e espaco comum ou NBSP contam como
whitespace e somem. U+2800 nao e whitespace em Unicode, entao sobrevive ao corte
e renderiza invisivel — e o unico jeito de ganhar um respiro entre a status line
e a linha de modo (`auto mode on...`). Delete se nao quiser o espaco.

---

## 📁 Estrutura

```
claude-code-status-line/
├── statusline-command.sh   # Script principal da status line
├── install.sh              # Instalador automatico
├── uninstall.sh            # Desinstalador
├── LICENSE                 # MIT License
└── README.md               # Voce esta aqui
```

---

## ⚙️ Como funciona

O Claude Code envia um JSON via `stdin` para o script configurado em `statusLine.command` a cada atualizacao. O JSON contem:

```json
{
  "model": { "display_name": "Opus 5 (1M context)" },
  "workspace": { "project_dir": "/home/user/projeto" },
  "context_window": { "used_percentage": 30 },
  "cost": { "total_lines_added": 312, "total_lines_removed": 89 },
  "rate_limits": {
    "five_hour": { "used_percentage": 57, "resets_at": 1775811600 },
    "seven_day": { "used_percentage": 31, "resets_at": 1776128400 }
  }
}
```

O script parseia esse JSON com **bash puro** (sem `jq`, sem `bc`, sem dependencias externas) e monta a saida formatada com cores ANSI. O `resets_at` (timestamp Unix) alimenta tanto o contador de reset quanto o calculo de ritmo 🧊/🔥.

Testar sem abrir o Claude Code:

```bash
echo '{"display_name":"Opus 5","cwd":"/tmp/projeto","context_window":{"used_percentage":30},"five_hour":{"used_percentage":57,"resets_at":'$(( $(date +%s) + 9420 ))'}}' \
  | bash statusline-command.sh
```

---

## 🤝 Contribuindo

1. Fork o repositorio
2. Crie sua branch (`git checkout -b feature/minha-feature`)
3. Commit suas mudancas (`git commit -m 'Add minha feature'`)
4. Push para a branch (`git push origin feature/minha-feature`)
5. Abra um Pull Request

---

## 📄 Licenca

Este projeto esta sob a licenca MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---

<p align="center">
  Feito com 🐙 por <a href="https://github.com/MatheusNunesBoraso">Matheus Nunes Boraso</a>
</p>
