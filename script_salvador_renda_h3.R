# Script para gerar mapa de Renda Média em Alta Resolução - Salvador
# Usando grid hexagonal H3 (menor unidade possível)

library(cnefetools)
library(dplyr)
library(geobr)
library(mapview)
library(leafpop)
library(htmlwidgets)

# 1. Obter código IBGE de Salvador
salvador_ibge <- lookup_muni(name_muni = "Salvador")$code_muni

# 2. Interpolar renda média para grid hexagonal H3
# Resolução 9 = hexágonos de aproximadamente 0.1 km² (alta resolução)
# Resolução 10 = hexágonos ainda menores (~0.015 km²) - pode ser muito detalhado
cat("Iniciando interpolação para grid H3 de alta resolução...\n")
cat("Isso pode levar alguns minutos devido ao nível de detalhe.\n\n")

salvador_h3_renda <- tracts_to_h3(
  code_muni = salvador_ibge,
  h3_resolution = 9,  # Alta resolução - hexágonos pequenos
  vars = c('pop_ph', 'avg_inc_resp'),
  cache = TRUE,
  verbose = TRUE
)

# 3. Carregar bairros de Salvador para fazer spatial join
salvador_bairros <- read_neighborhood(year = 2022, simplified = FALSE) |>
  filter(name_muni == "Salvador") |>
  sf::st_transform(sf::st_crs(salvador_h3_renda))  # Converter para mesmo CRS do H3

# 4. Fazer spatial join: descobrir qual bairro cada hexágono pertence
# Usar st_join com largest = TRUE para o hexágono ficar com o bairro que mais o cobre
salvador_h3_renda <- sf::st_join(
  salvador_h3_renda,
  salvador_bairros |> select(name_neighborhood),
  join = sf::st_intersects,
  largest = TRUE
)

# 5. Filtrar hexágonos com dados válidos e população mínima
# Remove hexágonos sem dados ou com população muito baixa
salvador_h3_renda <- salvador_h3_renda |>
  filter(
    !is.na(avg_inc_resp),
    !is.na(pop_ph),
    pop_ph >= 5  # Pelo menos 5 pessoas para ter estatística significativa
  ) |>
  mutate(
    # Renda arredondada para inteiros
    renda_inteira = round(avg_inc_resp, 0),
    # População arredondada
    pop_inteira = round(pop_ph, 0)
  )

cat("\nTotal de hexágonos com dados válidos: ", nrow(salvador_h3_renda), "\n")
cat("Renda média geral: R$ ", round(mean(salvador_h3_renda$avg_inc_resp, na.rm = TRUE), 2), "\n")
cat("Renda mínima: R$ ", round(min(salvador_h3_renda$avg_inc_resp, na.rm = TRUE), 2), "\n")
cat("Renda máxima: R$ ", round(max(salvador_h3_renda$avg_inc_resp, na.rm = TRUE), 2), "\n\n")

# 6. Criar popup customizado com informações do bairro
criar_popup_h3 <- function(data) {
  # Se o nome do bairro for NA, usar "Bairro desconhecido"
  bairro <- ifelse(is.na(data$name_neighborhood), "Bairro desconhecido", data$name_neighborhood)
  
  popup_html <- sprintf(
    "<b>Bairro:</b> %s<br/>
     <b>Renda Média (R$):</b> %s<br/>
     <b>População:</b> %s pessoas<br/>
     <hr>
     <small>Resolução H3: Nível 9<br/>
     Área aproximada: ~0.1 km²</small>",
    bairro,
    format(round(data$avg_inc_resp), big.mark = ".", decimal.mark = ","),
    format(round(data$pop_ph), big.mark = ".", decimal.mark = ",")
  )
  return(popup_html)
}

# 7. Aplicar popups
popups_h3 <- sapply(1:nrow(salvador_h3_renda), function(i) criar_popup_h3(salvador_h3_renda[i, ]))

# 8. Criar label com bairro + classificação de renda
salvador_h3_renda <- salvador_h3_renda |>
  mutate(
    # Preencher NA com "Desconhecido" para criar labels limpos
    nome_bairro = ifelse(is.na(name_neighborhood), "Desconhecido", name_neighborhood),
    # Classificação de renda
    classe_renda = case_when(
      avg_inc_resp < 1000 ~ "Muito Baixa (< R$ 1.000)",
      avg_inc_resp < 2000 ~ "Baixa (R$ 1.000-2.000)",
      avg_inc_resp < 3000 ~ "Média-Baixa (R$ 2.000-3.000)",
      avg_inc_resp < 5000 ~ "Média (R$ 3.000-5.000)",
      avg_inc_resp < 10000 ~ "Média-Alta (R$ 5.000-10.000)",
      TRUE ~ "Alta (> R$ 10.000)"
    ),
    # Label combinado: Bairro + Classe de Renda
    label_tooltip = paste(nome_bairro, " - ", classe_renda, sep = "")
  )

# 9. Criar mapa interativo de Alta Resolução
# Usando paleta viridis: roxo escuro > verde > amarelo (mesma dos outros mapas)
mapa_renda_h3 <- mapview(
  salvador_h3_renda, 
  zcol = 'renda_inteira',
  layer.name = "Renda Média (R$) - Alta Resolução",
  alpha.regions = 0.8,
  popup = popups_h3,
  label = salvador_h3_renda$label_tooltip,
  col.regions = colorRampPalette(c("#440154", "#31688e", "#35b779", "#fde724"))(100)
)

# 10. Criar pasta para GitHub Pages (se não existe)
if (!dir.exists("docs")) {
  dir.create("docs")
}
if (!dir.exists("docs/mapas")) {
  dir.create("docs/mapas")
}

# 11. Salvar mapa como HTML
htmlwidgets::saveWidget(mapa_renda_h3@map, file = "docs/mapas/mapa_renda_alta_resolucao.html", selfcontained = FALSE)

# 12. Exibir o mapa
print(mapa_renda_h3)

cat("\nMapa de alta resolução criado com sucesso!\n")
cat("Arquivo HTML salvo em: docs/mapas/mapa_renda_alta_resolucao.html\n\n")

# 13. Estatísticas por classe de renda
cat("--- Distribuição de Hexágonos por Classe de Renda ---\n")
tabela_classes <- salvador_h3_renda |>
  as.data.frame() |>
  select(-geometry) |>
  count(classe_renda, sort = TRUE) |>
  mutate(percentual = round(n / sum(n) * 100, 2))

print(tabela_classes)

cat("\nRecursos do mapa:\n")
cat("  • Passar o mouse: exibe classificação de renda\n")
cat("  • Clicar: exibe renda exata e população do hexágono\n")
cat("  • Zoom: recomendado para visualizar detalhes em alta resolução\n")
cat("  • Cores: do claro (renda baixa) ao escuro (renda alta)\n")
