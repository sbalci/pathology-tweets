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
library("dplyr")
library("googlesheets4")


# https://drive.google.com/drive/folders/1tAQ3yWgpV6Syg6p-Ns4E0VHHf16kgirT?usp=sharing

# https://docs.google.com/spreadsheets/d/1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A/edit?usp=sharing


# tidytags::read_tags(tags_id = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")

googlesheets4::gs4_get(ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A")

currentTweets <- googlesheets4::range_read(
  ss = "1om6T_FqSoBbWDn30R2i4tP-KrS_N05tlQ-YFF_-f74A",
  sheet = "Archive",
range = "A1:R100"
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
  "./currentTweets",
  justNowTimeStamp,
  ".qmd")

writeLines(
  text = currentTweetsText,
  con = currentTweets_qmd
)

currentTweets_html <- paste0(
  "./htmls/currentTweets",
  justNowTimeStamp,
  ".html")

quarto::quarto_render(input = currentTweets_qmd,
                      output_format = "html",
                      output_file = currentTweets_html,
                      use_freezer = TRUE,
                      cache = TRUE,
                      )

