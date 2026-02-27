library(cnefetools); library(dplyr); library(geobr); library(mapview)

## Puxando código IBGE de Feira de Santana
fds_ibge <- lookup_muni(name_muni = "Feira de Santana")$code_muni

## Intepolar pra malha hexagonal H3 de resolução 8
fds_h3 <- tracts_to_h3(code_muni = fds_ibge,
                       h3_resolution = 8,
                       vars = c('pop_ph','avg_inc_resp'))

mapview(fds_h3, zcol = 'pop_ph', layer.name = "Pop. Dom. Part.")

mapview(fds_h3, zcol = 'avg_inc_resp', layer.name = "Renda Méd. Resp")


## Interpolar pra bairros de FDS
fds_brr <- read_neighborhood(year = 2022, simplified = F) |> 
  filter(name_muni == "Feira de Santana")

mapview(fds_brr)

fds_brr_int <- tracts_to_polygon(code_muni = fds_ibge,
                                 polygon = fds_brr,
                                 vars = c('pop_ph','avg_inc_resp')
                                 )

mapview(fds_brr_int, zcol = 'pop_ph', layer.name = "Pop. Dom. Part.")

mapview(fds_brr_int, zcol = 'avg_inc_resp', layer.name = "Renda Méd. Resp")
