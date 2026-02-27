# Script para gerar gráficos INTERATIVOS de População por Faixa Etária - Salvador
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

# 3. Interpolar dados de faixas etárias para os bairros
# Variáveis: populações por grupo etário + população total do bairro
salvador_bairros_faixa <- tracts_to_polygon(
  code_muni = salvador_ibge,
  polygon = salvador_bairros,
  vars = c('pop_ph', 'age_0_4', 'age_5_9', 'age_10_14', 'age_60_69', 'age_70m'),
  verbose = TRUE
)

# 4. Calcular populações por faixa etária e percentuais
salvador_bairros_faixa <- salvador_bairros_faixa |>
  mutate(
    # Somar população com menos de 14 anos (0-4, 5-9, 10-14)
    pop_menor_14 = age_0_4 + age_5_9 + age_10_14,
    # Somar população com 60 anos ou mais (60-69, 70+)
    pop_maior_60 = age_60_69 + age_70m,
    # Arredondar valores
    pop_menor_14_arred = round(pop_menor_14, 0),
    pop_maior_60_arred = round(pop_maior_60, 0),
    # Calcular percentuais em relação à população do bairro
    perc_jovens = round((pop_menor_14 / pop_ph) * 100, 2),
    perc_idosos = round((pop_maior_60 / pop_ph) * 100, 2)
  )

# 5. Criar popup customizado para População < 14 anos
criar_popup_jovens <- function(data) {
  popup_html <- sprintf(
    "<b>Bairro:</b> %s<br/>
     <b>População < 14 anos:</b> %s<br/>
     <b>Percentual do bairro:</b> %.2f%%<br/>
     <hr>
     <b>Detalhamento:</b><br/>
     - 0-4 anos: %s<br/>
     - 5-9 anos: %s<br/>
     - 10-14 anos: %s",
    data$name_neighborhood,
    format(round(data$pop_menor_14), big.mark = ".", decimal.mark = ","),
    data$perc_jovens,
    format(round(data$age_0_4), big.mark = ".", decimal.mark = ","),
    format(round(data$age_5_9), big.mark = ".", decimal.mark = ","),
    format(round(data$age_10_14), big.mark = ".", decimal.mark = ",")
  )
  return(popup_html)
}

# 6. Criar popup customizado para População > 60 anos
criar_popup_idosos <- function(data) {
  popup_html <- sprintf(
    "<b>Bairro:</b> %s<br/>
     <b>População > 60 anos:</b> %s<br/>
     <b>Percentual do bairro:</b> %.2f%%<br/>
     <hr>
     <b>Detalhamento:</b><br/>
     - 60-69 anos: %s<br/>
     - 70+ anos: %s",
    data$name_neighborhood,
    format(round(data$pop_maior_60), big.mark = ".", decimal.mark = ","),
    data$perc_idosos,
    format(round(data$age_60_69), big.mark = ".", decimal.mark = ","),
    format(round(data$age_70m), big.mark = ".", decimal.mark = ",")
  )
  return(popup_html)
}

# 7. Aplicar popups
popups_jovens <- sapply(1:nrow(salvador_bairros_faixa), function(i) criar_popup_jovens(salvador_bairros_faixa[i, ]))
popups_idosos <- sapply(1:nrow(salvador_bairros_faixa), function(i) criar_popup_idosos(salvador_bairros_faixa[i, ]))

# 8. Criar mapa interativo de População com Menos de 14 Anos
mapa_menor_14 <- mapview(
  salvador_bairros_faixa, 
  zcol = 'pop_menor_14_arred', 
  layer.name = "Pop. < 14 Anos",
  alpha.regions = 0.7,
  popup = popups_jovens,
  label = salvador_bairros_faixa$name_neighborhood
)

# 9. Criar mapa interativo de População com Mais de 60 Anos
mapa_maior_60 <- mapview(
  salvador_bairros_faixa, 
  zcol = 'pop_maior_60_arred', 
  layer.name = "Pop. > 60 Anos",
  alpha.regions = 0.7,
  popup = popups_idosos,
  label = salvador_bairros_faixa$name_neighborhood
)

# 10. Criar pasta para GitHub Pages (se ainda não existe)
if (!dir.exists("docs")) {
  dir.create("docs")
}
if (!dir.exists("docs/mapas")) {
  dir.create("docs/mapas")
}

# 11. Salvar mapas como HTML
htmlwidgets::saveWidget(mapa_menor_14@map, file = "docs/mapas/mapa_menores_14.html", selfcontained = FALSE)
htmlwidgets::saveWidget(mapa_maior_60@map, file = "docs/mapas/mapa_maiores_60.html", selfcontained = FALSE)

# 12. Exibir os mapas
print(mapa_menor_14)
print(mapa_maior_60)

cat("\nMapas salvos como HTML em: docs/mapas/\n")

# 13. Visualizar estatísticas básicas
cat("\n--- Estatísticas da População com Menos de 14 Anos ---\n")
print(summary(salvador_bairros_faixa$pop_menor_14))

cat("\n--- Estatísticas da População com 60+ Anos ---\n")
print(summary(salvador_bairros_faixa$pop_maior_60))

cat("\n--- Percentuais Médios por Bairro ---\n")
cat("Jovens (< 14 anos): ", round(mean(salvador_bairros_faixa$perc_jovens, na.rm = TRUE), 2), "%\n", sep = "")
cat("Idosos (> 60 anos): ", round(mean(salvador_bairros_faixa$perc_idosos, na.rm = TRUE), 2), "%\n", sep = "")

cat("\nMapas interativos criados com sucesso!\n")
cat("- Mapa Menores de 14 Anos: mapa_menor_14\n")
cat("- Mapa Maiores de 60 Anos: mapa_maior_60\n")
cat("\nRecursos:\n")
cat("  • Passar o mouse: exibe nome do bairro\n")
cat("  • Clicar: exibe população arredondada e percentual do bairro\n")
cat("  • Popups incluem detalhamento por faixa etária específica\n")
