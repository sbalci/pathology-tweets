if (!requireNamespace("tidytags", quietly = TRUE)) {
  install.packages(
    "tidytags",
    dependencies = TRUE,
    quiet = TRUE,
    verbose = FALSE
  )
}
library("tidytags")
library("magrittr")
library("dplyr", quietly = TRUE, warn.conflicts = FALSE)
library("googlesheets4")


# https://drive.google.com/drive/folders/1tAQ3yWgpV6Syg6p-Ns4E0VHHf16kgirT?usp=sharing

# https://docs.google.com/spreadsheets/d/1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A/edit?usp=sharing


# currentTweetsAll <- tidytags::read_tags(tags_id = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")

googlesheets4::gs4_get(ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")



currentTweets <- googlesheets4::range_read(
  ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A",
  sheet = "Archive",
range = "A1:R101"
)



# {{< tweet serdarbalci 1269671183114526722 >}}


currentTweets <-
  currentTweets %>%
  dplyr::select(
    from_user,
    id_str
  )

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

currentTweets <- sample_n(currentTweets, 10)

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
  "title: Pathology Tweets ", justNowTimeStamp, " \n",
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

quarto::quarto_render(input = currentTweets_qmd,
                      output_format = "html",
                      output_file = currentTweets_html,
                      use_freezer = TRUE,
                      cache = TRUE,
                      debug = TRUE
                      )

# file.exists(paste0("./docs/_htmls/currentTweets",justNowTimeStamp, ".html"))

# list.files(path = "./docs/_htmls/", pattern = "*.html", full.names = TRUE)

html_files <- list.files(path = "./_htmls/", pattern = "*.html", full.names = TRUE)


fs::file_move(path = html_files, new_path = "./pages/")



list_of_pages <- list.files("./pages/", full.names = FALSE)

list_of_pages_fullnames <- list.files("./pages/", full.names = TRUE)


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



quarto::quarto_render(".", as_job = FALSE)


knitroot <- here::here(fs::path_home(), "Documents/GitHub/pathology-tweets")


CommitMessage <-
  paste("updated at: ", Sys.time(), sep = "")

setorigin <-
  "git remote set-url origin git@github.com:sbalci/pathology-tweets &&"

gitCommand <-
  paste('cd ',
        knitroot,
        ' && git add . && git commit --message "',
        CommitMessage,
        '" && ',
        setorigin,
        ' git push origin main ',
        sep = ''
  )

tryCatch({
  shell(
    cmd = gitCommand,
    intern = TRUE,
    wait = TRUE
  )

},
error = function(error_message) {
  message("sbalci/pathology-tweets update")
  message(error_message)
  message("\n")
  return(NA)
}
)

