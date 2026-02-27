# 📊 Mapas Interativos de Salvador - Análise Populacional

Este repositório contém mapas interativos da cidade de Salvador (BA) com análises populacionais baseadas nos dados do Censo 2022 do IBGE.

## 🗺️ Mapas Disponíveis

### Renda e População
- **População por Bairro**: Distribuição populacional em domicílios particulares
- **Renda Média por Bairro**: Renda média do responsável por domicílio
- **Renda em Alta Resolução (H3)**: Mapa detalhado usando grid hexagonal H3 com resolução 9 (~0.1 km² por hexágono)

### Faixa Etária
- **População < 14 Anos**: Distribuição de jovens por bairro com breakdown detalhado
- **População > 60 Anos**: Distribuição de idosos por bairro com breakdown detalhado

## 🚀 Como visualizar os mapas

### Opção 1: GitHub Pages (após deploy)
Acesse: `https://SEU_USUARIO.github.io/SEU_REPOSITORIO/`

### Opção 2: Localmente
1. Clone o repositório
2. Abra o arquivo `docs/index.html` em um navegador web

## 📂 Estrutura do Projeto

```
.
├── docs/
│   ├── index.html              # Página principal com menu
│   └── mapas/
│       ├── mapa_populacao.html
│       ├── mapa_renda.html
│       ├── mapa_renda_alta_resolucao.html  # Grid H3 alta resolução
│       ├── mapa_menores_14.html
│       └── mapa_maiores_60.html
├── script_salvador_renda_populacao.R
├── script_salvador_renda_h3.R              # Novo: Grid H3 alta resolução
└── script_salvador_faixa_etaria.R
```

## ⚙️ Como configurar GitHub Pages

1. **Fazer push do código para o GitHub**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Mapas interativos de Salvador"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/SEU_REPOSITORIO.git
   git push -u origin main
   ```

2. **Ativar GitHub Pages**:
   - Acesse o repositório no GitHub
   - Vá em **Settings** → **Pages**
   - Em **Source**, selecione **main** branch
   - Em **Folder**, selecione **/docs**
   - Clique em **Save**
   - Aguarde alguns minutos e acesse o link fornecido!

## 🔧 Tecnologias Utilizadas

- **R**: Linguagem de programação estatística
- **cnefetools**: Pacote para interpolação dasimétrica com dados do CNEFE
- **mapview**: Visualização interativa de dados espaciais
- **geobr**: Download de dados geográficos do Brasil
- **leaflet**: Biblioteca JavaScript para mapas interativos
- **htmlwidgets**: Salvamento de widgets R como HTML

## 📊 Metodologia

Os mapas utilizam **interpolação dasimétrica** através do pacote `cnefetools`, que distribui dados de setores censitários para bairros usando pontos de endereço do CNEFE (Cadastro Nacional de Endereços para Fins Estatísticos).

### Grid Hexagonal H3

O mapa de renda em alta resolução utiliza o **sistema H3** da Uber, que divide o mundo em hexágonos de tamanhos uniformes. Características:

- **Resolução 9**: Cada hexágono cobre aproximadamente 0.1 km²
- **1.940 hexágonos** em Salvador com dados válidos
- **Granularidade**: Nível de quarteirão, permitindo identificar variações locais de renda
- **Vantagens**: Hexágonos são melhores que quadrados para análise espacial pois têm distância uniforme entre centros e vizinhos

### Variáveis Disponíveis

**Renda e População:**
- `pop_ph`: População em domicílios particulares
- `avg_inc_resp`: Renda média do responsável

**Faixa Etária:**
- `age_0_4`, `age_5_9`, `age_10_14`: População jovem (< 14 anos)
- `age_60_69`, `age_70m`: População idosa (> 60 anos)

## 📈 Estatísticas de Salvador (2022)

- **População Total**: 2.402.708 habitantes
- **Jovens (< 14 anos)**: 16,53% em média por bairro
- **Idosos (> 60 anos)**: 17,19% em média por bairro

### Distribuição de Renda (Grid H3 - Alta Resolução)
- **Renda Média Geral**: R$ 3.523,46
- **Renda Mínima**: R$ 844,08
- **Renda Máxima**: R$ 58.598,44
- **Total de hexágonos**: 1.940

**Distribuição por Classe de Renda:**
- Muito Baixa (< R$ 1.000): 2,37%
- Baixa (R$ 1.000-2.000): 55,88%
- Média-Baixa (R$ 2.000-3.000): 13,20%
- Média (R$ 3.000-5.000): 8,92%
- Média-Alta (R$ 5.000-10.000): 11,13%
- Alta (> R$ 10.000): 8,51%

## 🎯 Recursos Interativos

- **Hover**: Passa o mouse para ver nome do bairro
- **Click**: Clique para informações detalhadas (população, percentuais, etc.)
- **Zoom/Pan**: Navegue livremente pelo mapa
- **Camadas**: Alterne entre diferentes mapas base

## 📝 Fonte de Dados

- **IBGE** - Censo Demográfico 2022
- **CNEFE 2022** - Cadastro Nacional de Endereços para Fins Estatísticos
- **H3** - Sistema de indexação geoespacial hexagonal da Uber (para mapa de alta resolução)

## 📄 Licença

MIT License - Sinta-se livre para usar e modificar para seus próprios projetos.

## 👤 Autor

Criado com ❤️ usando R e mapview

---

**Nota**: Para regenerar os mapas, execute os scripts R na raiz do projeto:
```r
source("script_salvador_renda_populacao.R")
source("script_salvador_renda_h3.R")          # Mapa de alta resolução
source("script_salvador_faixa_etaria.R")
```
