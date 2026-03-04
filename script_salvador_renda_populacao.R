# Script para gerar gráficos INTERATIVOS de Renda Média e População por Bairro - Salvador
# Usando o pacote cnefetools e mapview para visualização interativa

library(cnefetools)
library(dplyr)
library(geobr)
library(mapview)
library(leafpop)
library(htmlwidgets)

# 1. Obter código IBGE de Salvador
salvador_ibge <- lookup_muni(name_muni = "Salvador")$code_muni

# 2. Ler os bairros de Salvador
salvador_bairros <- read_neighborhood(year = 2022, simplified = FALSE) |>
  filter(name_muni == "Salvador")

# 3. Interpolar dados de renda média, população e idade para os bairros
# Usando dasymetric interpolation dos setores censitários
salvador_bairros_int <- tracts_to_polygon(
  code_muni = salvador_ibge,
  polygon = salvador_bairros,
  vars = c('pop_ph', 'avg_inc_resp', 'age_60_69', 'age_70m'),
  verbose = TRUE
)

# 4. Preparar dados com formatação customizada
# Calcular população total de Salvador
pop_total <- sum(salvador_bairros_int$pop_ph, na.rm = TRUE)

# Criar versão com dados formatados
salvador_bairros_int <- salvador_bairros_int |>
  mutate(
    # Renda arredondada para inteiros
    renda_arredondada = round(avg_inc_resp, 0),
    # Percentual da população da cidade
    percentual_pop = round((pop_ph / pop_total) * 100, 2),
    # População com 60 anos ou mais
    pop_maior_60 = age_60_69 + age_70m,
    # Proporção de idosos em relação à população do bairro
    perc_idosos = round((pop_maior_60 / pop_ph) * 100, 2)
  )

# 5. Criar popup customizado para População
criar_popup_pop <- function(data) {
  popup_html <- sprintf(
    "<b>Bairro:</b> %s<br/>
     <b>População:</b> %s",
    data$name_neighborhood,
    format(round(data$pop_ph), big.mark = ".", decimal.mark = ",")
  )
  return(popup_html)
}

# 6. Criar popup customizado para Renda
criar_popup_renda <- function(data) {
  popup_html <- sprintf(
    "<b>Bairro:</b> %s<br/>
     <b>Renda Média (R$):</b> %s",
    data$name_neighborhood,
    format(round(data$avg_inc_resp), big.mark = ".", decimal.mark = ",")
  )
  return(popup_html)
}

# 7. Aplicar popups e criar mapas
popups_pop <- sapply(1:nrow(salvador_bairros_int), function(i) criar_popup_pop(salvador_bairros_int[i, ]))
popups_renda <- sapply(1:nrow(salvador_bairros_int), function(i) criar_popup_renda(salvador_bairros_int[i, ]))

# 8. Criar mapa interativo de População por Bairro
mapa_populacao <- mapview(
  salvador_bairros_int,
  zcol = 'pop_ph',
  layer.name = "População",
  alpha.regions = 0.7,
  popup = popups_pop,
  label = salvador_bairros_int$name_neighborhood
)

# 9. Criar mapa interativo de Renda Média por Bairro
mapa_renda <- mapview(
  salvador_bairros_int, 
  zcol = 'renda_arredondada', 
  layer.name = "Renda Média (R$)",
  alpha.regions = 0.7,
  popup = popups_renda,
  label = salvador_bairros_int$name_neighborhood
)

# 10. Criar pasta para GitHub Pages
if (!dir.exists("docs")) {
  dir.create("docs")
}
if (!dir.exists("docs/mapas")) {
  dir.create("docs/mapas")
}

# 11. Salvar mapas como HTML
htmlwidgets::saveWidget(mapa_populacao@map, file = "docs/mapas/mapa_populacao.html", selfcontained = FALSE)
htmlwidgets::saveWidget(mapa_renda@map, file = "docs/mapas/mapa_renda.html", selfcontained = FALSE)

# 12. Exibir os mapas
print(mapa_populacao)
print(mapa_renda)

cat("\nMapas interativos criados com sucesso!\n")
cat("Arquivos HTML salvos em: docs/mapas/\n")
cat("- Mapa de População: mapa_populacao\n")
cat("- Mapa de Renda: mapa_renda\n")
cat("\nOs mapas foram criados e exibidos acima.\n")
cat("Você pode interagir com eles:\n")
cat("  • Passar o mouse: exibe nome do bairro\n")
cat("  • Clicar: exibe informações detalhadas\n")
cat("  • Zoom, pan e alternar camadas de fundo\n")
cat("\nPopulação total de Salvador: ", format(pop_total, big.mark = ".", decimal.mark = ","), " habitantes\n", sep = "")
