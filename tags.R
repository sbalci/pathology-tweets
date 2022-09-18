# if (!requireNamespace("tidytags", quietly = TRUE)) {
#   install.packages(
#     "tidytags",
#     dependencies = TRUE,
#     quiet = TRUE,
#     verbose = FALSE
#   )
# }
#
# if (!requireNamespace("tidytags", quietly = TRUE)) {
# install.packages("tidytags", repos = "https://ropensci.r-universe.dev", ,
#                  dependencies = TRUE,
#                  quiet = TRUE,
#                  verbose = FALSE)
# }
#
# library("tidytags")

library("magrittr")
library("dplyr", quietly = TRUE, warn.conflicts = FALSE)
library("googlesheets4")


# https://drive.google.com/drive/folders/1tAQ3yWgpV6Syg6p-Ns4E0VHHf16kgirT?usp=sharing

# https://docs.google.com/spreadsheets/d/1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A/edit?usp=sharing


# currentTweetsAll <- tidytags::read_tags(tags_id = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")

# googlesheets4::gs4_get(ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")



# library(googledrive)
# library(googlesheets4)
# # Google sheets authentification -----------------------------------------------
# options(gargle_oauth_cache = ".secrets")
# drive_auth(cache = ".secrets", email = "drserdarbalci@gmail.com")
# gs4_auth(token = drive_token())


read_tags2 <-
  function(tags_id, sheet = 2, myrange = "A1:C501") {
    googlesheets4::gs4_deauth()
    tweet_sheet <- googlesheets4::range_read(ss = tags_id, sheet = sheet, range = myrange)
    tweet_sheet
  }


# https://docs.google.com/spreadsheets/d/1GMaLFpxDjzYkAYI27d77h0l3qtV_PTbOAcph-QM-Q5g/edit?usp=sharing


currentTweets_ImportTAGSPathology <- read_tags2(
  tags_id = "1GMaLFpxDjzYkAYI27d77h0l3qtV_PTbOAcph-QM-Q5g",
  sheet = "ImportTAGSPathology")

currentTweets_selected <- read_tags2(
  tags_id = "1GMaLFpxDjzYkAYI27d77h0l3qtV_PTbOAcph-QM-Q5g",
  sheet = "selected")


# https://docs.google.com/spreadsheets/d/e/2PACX-1vRk-FT0J0eydRoEkxDGDGqdezHg278qoIX-pNC4LtJdpQqF1RC9T45a-UIfZM-0yO_5SEjTOF6u_R-o/pubhtml


# currentTweetsAll <- read_tags2(tags_id = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")

# currentTweetsAll <- googlesheets4::range_read(
#   ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A",
#   sheet = "Archive",
# range = "A1:R101"
# )

# saveRDS(object = currentTweetsAll, file = "currentTweetsAll.RDS")

# {{< tweet serdarbalci 1269671183114526722 >}}


currentTweetsAll <- rbind(
  currentTweets_ImportTAGSPathology,
  currentTweets_selected
)

removePattern <- "^RT|Donald|Trump|election"

currentTweetsAll <- currentTweetsAll[!grepl(removePattern, currentTweetsAll$text),]


currentTweets <-
  currentTweetsAll %>%
  dplyr::select(
    from_user,
    id_str
  )

currentTweets <- dplyr::sample_n(tbl = currentTweets, size = 10, replace = FALSE)


currentTweets <-
  currentTweets %>%
  dplyr::mutate(
    embedCodes = paste0("{{< tweet ",
      from_user,
      " ",
      id_str,
      " >}}"
    )
  )


justNowTimeStamp <- gsub(
  pattern = "-|:| ",
  replacement = "",
  x = as.character(Sys.time())
  )

currentTweetsText <- paste0(
  currentTweets$embedCodes,
  "\n\n\n","---", "\n\n\n",
  collapse = "\n"
)

currentTweetsText <- paste0(
  "---", "\n",
  "title: 'Pathology Tweets ", justNowTimeStamp, "' \n",
  "---", "\n",
  "\n\n",
  currentTweetsText,
  collapse = "\n"
)

currentTweets_qmd <- paste0(
  "./_htmls/currentTweets",
  justNowTimeStamp,
  ".qmd")

writeLines(
  text = currentTweetsText,
  con = currentTweets_qmd
)

currentTweets_html <- paste0(
  "./_htmls/currentTweets",
  justNowTimeStamp,
  ".html")


# quarto::quarto_render(input = "currentTweets20220914005302.qmd",
#                       output_format = "html",
#                       output_file = currentTweets_html,
#                       execute_dir = here::here(),
#                       cache = TRUE,
#                       debug = TRUE,
#                       as_job = FALSE
#                       )

quarto::quarto_render(input = currentTweets_qmd,
                      output_format = "html",
                      output_file = currentTweets_html,
                      cache = TRUE,
                      debug = TRUE,
                      as_job = FALSE
                      )

# file.exists(paste0("./docs/_htmls/currentTweets",justNowTimeStamp, ".html"))

# list.files(path = "./docs/_htmls/", pattern = "*.html", full.names = TRUE)

html_files <- list.files(path = "./_htmls/", pattern = "*.html", full.names = TRUE)


fs::file_move(path = html_files, new_path = "./pages/")



list_of_pages <- list.files("./pages/", full.names = FALSE)

list_of_pages_fullnames <- list.files("./pages", full.names = TRUE)


df_list_of_pages <-cbind(pages = list_of_pages,
                         links = list_of_pages_fullnames)

df_list_of_pages <- as.data.frame(df_list_of_pages)


df_list_of_pages <-df_list_of_pages %>%
dplyr::mutate(
  link_text = glue::glue("<a href='{links}'>{pages}</a>")
)




list_of_pages_text <- paste0(
  df_list_of_pages$link_text,
  "\n\n\n","---", "\n\n\n",
  collapse = "\n"
)





list_of_pages_text <- paste0(
  "---", "\n",
  "title: List of Pages ", " \n",
  "---", "\n",
  "\n\n",
  list_of_pages_text,
  collapse = "\n"
)


writeLines(
  text = list_of_pages_text,
  con = "./list.qmd"
)



html_extra_files <- list.files(path = "./_htmls/", pattern = "*_files", full.names = TRUE)

fs::dir_delete(html_extra_files)

md_files <- list.files(path = "./_htmls/", pattern = "*.md|*qmd", full.names = TRUE)

fs::file_delete(md_files)

quarto::quarto_render(".", as_job = FALSE)




# knitroot <- here::here(fs::path_home(), "Documents/GitHub/pathology-tweets")
#
#
# CommitMessage <-
#   paste("updated at: ", Sys.time(), sep = "")
#
# setorigin <-
#   "git remote set-url origin git@github.com:sbalci/pathology-tweets &&"
#
#
#
# gitCommand <-
#   paste('cd ',
#         knitroot,
#         ' && git add . && git commit --message "',
#         CommitMessage, '"',
#         ' && ',
#         setorigin,
#         ' git push origin main ',
#         sep = ''
#   )
#
#
# if(Sys.info()[["sysname"]] == "Darwin") {
#
#
# tryCatch({
#   system(
#     command = gitCommand,
#     intern = TRUE,
#     wait = TRUE
#   )
#
# },
# error = function(error_message) {
#   message("sbalci/pathology-tweets update")
#   message(error_message)
#   message("\n")
#   return(NA)
# }
# )
#
# }



# myTerm <- rstudioapi::terminalCreate(show = FALSE)
#
# rstudioapi::terminalSend(
#   myTerm,
#   paste0(gitCommand, "\n")
# )
#
# repeat {
#   Sys.sleep(0.1)
#   if (rstudioapi::terminalBusy(myTerm) == FALSE) {
#     print("Code Executed")
#     break
#   }
# }


