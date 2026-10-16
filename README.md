# Mapa de Indicadores de Saneamento de Santa Catarina

Painel estatico de distribuicao espacial dos indicadores de desempenho dos
servicos de abastecimento de agua e esgotamento sanitario nos 295 municipios
catarinenses, segundo a metodologia de regulacao por exposicao do Projeto
Sunshine (ProSun, ARSAE-MG), adaptada por Barbara Martins Folador.

Bases: SNIS (2003 a 2022) e SINISA (2023 e 2024).

## Estrutura

```
.
├── build.py                  gerador: le os xlsx e escreve public/index.html
├── src/template.html         template do painel (HTML, CSS e JS)
├── data/
│   ├── IN0xx_Resultado_Analise_SC.xlsx   8 planilhas de resultados
│   └── sc_municipios.geojson             malha municipal de SC
├── public/                   saida publicada (gerada pelo build)
├── vercel.json               configuracao de deploy estatico
├── requirements.txt
└── Makefile
```

## Rodar localmente

```bash
pip install -r requirements.txt
python build.py --csv
python -m http.server 8000 --directory public
```

Abra http://localhost:8000

Ou, com make: `make serve`

## Opcoes do gerador

| Opcao | Padrao | Para que serve |
|---|---|---|
| `--dados` | `./data` | pasta com os xlsx e o geojson |
| `--saida` | `./public` | pasta onde o HTML e escrito |
| `--ano-min` / `--ano-max` | 2003 / 2024 | recorte da serie historica |
| `--precisao` | 3 | casas decimais das coordenadas; menor valor gera arquivo menor |
| `--csv` | desligado | exporta tambem o CSV consolidado em formato longo |

Exemplo para reduzir o tamanho do arquivo:

```bash
python build.py --precisao 2
```

## Publicar no GitHub e na Vercel

### 1. Criar o repositorio

```bash
git init
git add .
git commit -m "Painel de indicadores de saneamento de SC"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/painel-saneamento-sc.git
git push -u origin main
```

### 2. Conectar na Vercel

1. Acesse vercel.com e entre com a conta do GitHub.
2. Clique em Add New > Project e selecione o repositorio.
3. Em Framework Preset escolha **Other**.
4. Build Command: deixe vazio. Output Directory: `public`.
5. Clique em Deploy.

O `public/index.html` ja esta versionado, entao a Vercel apenas serve o
arquivo, sem executar Python. Esse e o caminho mais simples e mais rapido.

### 3. Atualizar quando sair nova base

```bash
# substitua os xlsx em data/ e rode
python build.py --csv
git add data public
git commit -m "Atualiza serie com dados de 2025"
git push
```

A Vercel republica automaticamente a cada push na branch `main`.

### Alternativa: build na propria Vercel

Se preferir nao versionar o `public/index.html`, adicione ao `vercel.json`:

```json
"buildCommand": "pip install -r requirements.txt && python build.py"
```

Funciona, mas deixa o deploy mais lento e depende do runtime Python da
plataforma. Para um painel que muda uma vez por ano, versionar a saida e
melhor.

## Observacoes tecnicas

- **Malha com 293 poligonos.** A base geodata-br nao inclui Pescaria Brava
  (4212650) e Balneario Rincao (4220000). Os dados desses municipios existem
  nas planilhas, mas nao sao pintados. O `build.py` avisa isso no console.
  Para corrigir, substitua `data/sc_municipios.geojson` pela malha municipal
  2022 do IBGE.
- **Sentido dos indicadores.** Em IN049, IN082 e IN084, valor menor significa
  desempenho melhor. A classificacao ja vem pronta das planilhas, entao as
  cores estao corretas, mas o valor numerico no tooltip deve ser lido com esse
  cuidado.
- **Arquivo unico.** O HTML gerado embute o GeoJSON e os dados, sem dependencia
  de CDN ou API. Isso garante que o painel funcione offline e nao quebre por
  mudanca de servico externo.
- **Tamanho.** Cerca de 1.4 MB. Com `--precisao 2` cai para perto de 1.1 MB,
  sem perda visual perceptivel na escala do estado.

## Licenca dos dados

Dados publicos do SNIS (Ministerio das Cidades) e do SINISA (ANA). Malha
municipal derivada do IBGE. Resultados e classificacao elaborados pela autora.
