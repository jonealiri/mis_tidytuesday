
#Empezamos importando paquetes.

library(tidytuesdayR)
library(tidyverse)
library(tvthemes)
library(extrafont)
library(stringi)
library(ggtext)
library(ggthemes)
library(png)
library(grid)
library(patchwork)

#Cargamos los datos con la ayuda de tidituesdayR

datos_avatar <- tt_load("2020-08-11")

#Y leemos la documentaci�n:
  
readme(datos_avatar)

#Parece que tenemos dos bases de datos:
  
avatar <- datos_avatar$avatar
scena <- datos_avatar$scene_description

avatar

#En la documentaci�n he visto que nos han puesto
#el tipo de letra de Avatar, lo importaremos.


import_avatar()
loadfonts(quiet = TRUE)

#Primero voy a convertir a factor las variables
#book, character y chapter (con este �ltimo tengo
#dudas, por lo que crear� una nueva variable).

avatar <- avatar %>%
  mutate(book = as_factor(book),
         character = as_factor(character),
         chapter_fct = as_factor(chapter))

#A continuaci�n voy a contar las palabras de las columnas
#full_text y de character_words.

avatar <- avatar %>%
  mutate(
    words_total = stri_count_words(full_text),
    words_character = stri_count_words(character_words),
    words_no_character = (words_total - words_character))

#Crear� una nueva base de datos con los personajes
#que m�s palabras tienen en cada libro
#(me quedar� con los siete que m�s hablan de cada libro).

avatar_book <- avatar %>%
  group_by(book) %>%
  mutate(
    words_book_all = sum(words_total)
  ) %>%
  group_by(book, character) %>%
  summarise(
    words_book_all = mean(words_book_all),
    words_book = sum(words_character)
  ) %>%
  mutate(
    prop_word = words_book/words_book_all
  ) %>%
  group_by(book) %>%
  mutate(rank_character = min_rank(desc(words_book))) %>%
  filter(rank_character < 8) %>%
  group_by(character) %>%
  mutate(
    familia = str_replace_all(
      character, c("Sokka" = "ura", "Zuko" = "sua",
                   "Aang" = "avatar", "Katara" = "ura",
                   "Toph" = "lurra", "Azula" = "sua",
                   "Iroh" = "sua", "Zhao" = "sua",
                   "Jet" = "lurra", "Hama" = "ura")),
    familia = as_factor(familia))

#Crearemos el gr�fico base:
  
grafico_base1 <- avatar_book %>%
  ggplot(aes(x = book, y = desc(rank_character),
             col = character, group = character)) +
  geom_point(aes(col=familia)) +
  geom_line(aes(col=familia), linetype = "longdash") +
  scale_x_discrete(expand = c(0.1, 0.3)) +
  scale_colour_manual(values = c("#000066", "#aa0000", "#FF6600", "#003300"))

#Y ahora intentaremos pulirlo:
  
grafico_base2 <- grafico_base1 +
  labs(
    title = "<b>Chatterbox rank</b><br> <span style = 'font-size:7pt'>
    <span style = 'color:blue;'>**Sokka**</span> is the one with the most
    text considering all the books.<br><span style ='color:orange;'>**Aang**</span>
    and <span style = 'color:blue;'>**Katara**</span> have a downward trajectory.
    <br><span style = 'color:red;'>**Zuko**</span> is the most irregular.</span>"
    ) +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(
      size = 13,
      family = "Slayer",
      lineheight = 1,
      padding = margin(15, 15, 15, 15)),
    plot.caption = element_textbox_simple(
      size = 9,
      lineheight = 0.8,
      padding = margin(10, 10, 10, 10)
    )) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.text.x = element_text(family = "Arial"),
    axis.ticks.x = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "#fdf1e9"),
    plot.background = element_rect(fill = "#fdf1e9")
  ) +
  xlab(NULL) + ylab(NULL) 

#Insertamos anotaciones. 

grafico_base3 <- grafico_base2 +
  annotate("text", x = 3.05, y = -0.95, label = "Sokka",
           family = "Slayer", size = 3, color = "#000066",
           hjust = 0) +
  annotate("text", x = 3.05, y = -1.95, label = "Zuko",
           family = "Slayer", size = 3, color = "#aa0000",
           hjust = 0) +
  annotate("text", x = 3.05, y = -2.95, label = "Aang",
           family = "Slayer", size = 3, color = "#FF6600",
           hjust = 0) +
  annotate("text", x = 3.05, y = -3.95, label = "Katara",
           family = "Slayer", size = 3, color = "#000066",
           hjust = 0) +
  annotate("text", x = 2.05, y = -3.95, label = "Iroh",
           family = "Slayer", size = 3, color = "#aa0000",
           hjust = 0) +
  annotate("text", x = 3.05, y = -4.95, label = "Toph",
           family = "Slayer", size = 3, color = "#003300",
           hjust = 0) +
  annotate("text", x = 3.05, y = -5.95, label = "Azula",
           family = "Slayer", size = 3, color = "#aa0000",
           hjust = 0) +
  annotate("text", x = 1.05, y = -5.95, label = "Zhao",
           family = "Slayer", size = 3, color = "#aa0000",
           hjust = 0) +
  annotate("text", x = 3.05, y = -6.95, label = "Hama",
           family = "Slayer", size = 3, color = "#000066",
           hjust = 0) +
  annotate("text", x = 1.05, y = -6.95, label = "Jet",
           family = "Slayer", size = 3, color = "#003300",
           hjust = 0)

#Insertamos imagenes

grafico_base4 <- grafico_base3 +
  annotation_custom(rasterGrob(readPNG("Sokka.png"), interpolate = TRUE),
                    xmin = 0.5, xmax = 1, ymin = -3, ymax = -1) +
  annotation_custom(rasterGrob(readPNG("Zuko.png"), interpolate = TRUE),
                    xmin = 0.5, xmax = 1, ymin = -4.5, ymax = -3) +
  annotation_custom(rasterGrob(readPNG("Katara.png"), interpolate = TRUE),
                    xmin = 0.5, xmax = 1, ymin = -5, ymax = -6.5)

#Est� claro que pod�a haber creado alguna funci�n para
#las im�genes y las anotaciones. Pero todav�a no controlo
#las funciones, eso lo dejaremos para el futuro.

#Ahora voy a hacer un gr�fico de barras para cada libro.
#Las barras mostrar�n la proporci�n de palabras de cada
#personaje vs el total de palabras del libro. 

avatar_book %>%
  arrange(desc(prop_word)) %>%
  ggplot(aes(x=prop_word, y = character)) +
  geom_bar(stat="identity") +
  facet_wrap(~book, 3,1, scales = "free_y")

#No consigo ordenar las barras en cada faceta, as� que voy
#a hacer un gr�fico por libro.

water_fig <- avatar_book %>%
  filter(book == "Water") %>%
  ggplot(aes(x = reorder(character, prop_word), y = prop_word*100, fill = familia)) +
  geom_bar(stat="identity") +
  scale_y_continuous(limits = c(0,7)) +
  scale_fill_manual(
    values = c("#000066", "#aa0000", 
               "#FF6600", "#003300")) +
  coord_flip()

earth_fig <- avatar_book %>%
  filter(book == "Earth") %>%
  ggplot(aes(x = reorder(character, prop_word), y = prop_word*100, fill = familia)) +
  geom_bar(stat="identity") +
  scale_y_continuous(limits = c(0,7)) +
  scale_fill_manual(
    values = c("#000066", "#aa0000", 
               "#FF6600", "#003300")) +
  coord_flip()

fire_fig <- avatar_book %>%
  filter(book == "Fire") %>%
  ggplot(aes(x = reorder(character, prop_word), y = prop_word*100, fill = familia)) +
  geom_bar(stat="identity") +
  scale_y_continuous(limits = c(0,7)) +
  scale_fill_manual(
    values = c("#000066", "#aa0000", 
               "#FF6600", "#003300")) +
  coord_flip() 

#A�ado temas y colores

water_fig2 <- water_fig +
  labs(title = "Book 1: Water") +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(
      size = 8,
      family = "Slayer",
      padding = margin(8,8,8,8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    axis.text.y = element_text(
      family = "Slayer",
      size = 6),
    axis.ticks.y = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "#fdf1e9"),
    plot.background = element_rect(fill = "#fdf1e9")
  ) +
  ylab(NULL) + xlab(NULL)

earth_fig2 <- earth_fig +
  labs(title = "Book 2: Earth") +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(
      size = 8,
      family = "Slayer",
      padding = margin(8,8,8,8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    axis.text.y = element_text(
      family = "Slayer",
      size = 6),
    axis.ticks.y = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "#fdf1e9"),
    plot.background = element_rect(fill = "#fdf1e9")
  ) +
  ylab(NULL) + xlab(NULL)

fire_fig2 <- fire_fig +
  labs(title = "Book 3: Fire") +
  theme(
    plot.title.position = "plot",
    plot.title = element_textbox_simple(
      size = 8,
      family = "Slayer",
      padding = margin(8,8,8,8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    axis.text.y = element_text(
      family = "Slayer",
      size = 6),
    axis.ticks.y = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "#fdf1e9"),
    plot.background = element_rect(fill = "#fdf1e9")
  ) +
  ylab(NULL) + xlab(NULL)

# Usando patchwork juntar� los gr�ficos

combinacion <- grafico_base4 / (water_fig2 + earth_fig2 + fire_fig2) +
  plot_layout(heights = c(4,2))
combinacion + plot_annotation(caption = "Data: 'appa' R package by Avery Robbins
       Figure: @jonealiri")

ggsave("./avatar2.pdf", width = 9,
       height = 6, device = cairo_pdf)