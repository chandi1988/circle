#' Github information
#'
#' @description
#' Retrieves metadata about a Git repository from GitHub.
#'
#' `github_info()` returns a list as obtained from the GET "/repos/:repo" API.
#'
#' @param path `[string]`\cr
#'   The path to a GitHub-enabled Git repository (or a subdirectory thereof).
#' @family GitHub functions
github_info <- function(path = usethis::proj_get()) {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

#' @description
#' `github_repo()` returns the true repository name as string.
#' @param info `[list]`\cr
#'   GitHub information for the repository, by default obtained through
#'   [github_info()].
#'
#' @export
#' @keywords internal
#' @rdname github_info
github_repo <- function(path = usethis::proj_get(),
                        info = github_info(path)) {
  paste(info$owner$login, info$name, sep = "/") # nocov
}

get_repo_data <- function(repo) {
  req <- gh::gh("/repos/:repo", repo = repo)
  return(req)
}

get_remote_url <- function(path) {
  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if (!length(remote_names)) {
    stop("Failed to lookup git remotes") # nocov
  }
  remote_name <- "origin"
  if (!("origin" %in% remote_names)) { # nocov start
    remote_name <- remote_names[1]
    warning(sprintf("No remote 'origin' found. Using: %s", remote_name))
  } # nocov end
  git2r::remote_url(r, remote_name)
}

extract_repo <- function(url) {
  # Borrowed from gh:::github_remote_parse
  re <- "github[^/:]*[/:]([^/]+)/(.*?)(?:\\.git)?$"
  m <- regexec(re, url)
  match <- regmatches(url, m)[[1]]

  if (length(match) == 0) {
    stop("Unrecognized repo format: ", url) # nocov
  }

  paste0(match[2], "/", match[3])
}
